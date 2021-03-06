# NOTE: Ported Python -> Ruby
# from https://github.com/aws-samples/lambda-apigateway-twilio-tutorial

# Twilio Ingest Lambda handler code
# Receive an image URL from Twilio
# Apply a filter to the image and store in S3
# Return filtered image URL to the user

# NOTE: In Ruby Lambda world, you'll need to define the methods used before using them
# TODO: To be double checked ^^

# class TwilioClient
#   DEFAULT_PHONE_NUMBER = ENV["TWILIO_PHONE_NUMBER"]
#
#   def self.create_message(message, to)
#     @twilio_client.messages.create(from: DEFAULT_PHONE_NUMBER, to: to, body: message)
#   end
# end

# Using 'p' as it provides better logging in AWS CloudWatch (uses `.inspect`)
def log(msg = "")
  p "QuickTrack - #{msg}"
end

def setup_variables
  load_paths = Dir[ENV["GEM_PATH"]]
  $LOAD_PATH.unshift(*load_paths)

  log "$LOAD_PATH: #{$LOAD_PATH}"

  # TODO: Fix nokogiri
  # Commenting out Nokogiri for now (compiling gem on Lambda doesn't work at the moment w/o additional workarounds)
  # https://www.stevenringo.com/ruby-in-aws-lambda-with-postgresql-nokogiri/
  # https://blog.francium.tech/using-ruby-gems-with-native-extensions-on-aws-lambda-aa4a3b8862c9
  # require "nokogiri"
  #require "twilio-ruby"
  require "aws-record"
  require "aws-sdk-s3"
  require "aws-sdk-dynamodb"
  require "dotenv"
  require "fileutils"
  require "json"
  require "securerandom"
  require "open-uri"

  Dotenv.load

  # TODO: Use AWS Param Store or Key Manager?
  # https://github.com/rwiturralde/sam-lambda-param-store/blob/master/lambda-parameter-store-sam-template.yaml
  # https://aws.amazon.com/blogs/compute/sharing-secrets-with-aws-lambda-using-aws-systems-manager-parameter-store/
  @region_name = ENV["REGION_NAME"]
  @dynamodb_table_name = ENV["DDB_TABLE"]
  @dynamodb = Aws::DynamoDB::Client.new(region: @region_name)
  #@twilio_client = Twilio::REST::Client.new ENV["TWILIO_ACCOUNT_SID"], ENV["TWILIO_AUTH_TOKEN"]

  @s3_bucket_name = ENV["BUCKET_NAME"]
  @s3_prefix = "ingest-images/"
  @s3 = Aws::S3::Resource.new(region: @region_name)
end

def download_image(url, filename)
  case io = open(url)
  when StringIO then File.open("/tmp/#{filename}", "w") { |f| f.write(io) }
  when Tempfile then io.close; FileUtils.mv(io.path, "/tmp/#{filename}")
  end
end

# Reference http://docs.aws.amazon.com/AmazonS3/latest/dev/UploadObjSingleOpRuby.html
# Reference http://docs.aws.amazon.com/AmazonS3/latest/dev/acl-overview.html
def upload_to_s3(bucket_name, key, file)
  obj = @s3.bucket(bucket_name).object(key)
  obj.upload_file(file, { acl: "public-read" })
  obj.public_url  # Returns Public URL to the file
end

def put_item(from_number, name = nil, message = nil, pic_url = nil, num_media = nil)
  item = {
    fromNumber: from_number,
    name: name,
    message: message,
    picUrl: pic_url,
    numMedia: num_media,
    createdAt: Time.now.to_s
  }

  params = {
    item: item,
    table_name: @dynamodb_table_name
  }

  result = @dynamodb.put_item(params)
  result.to_h
end

# TODO: Make paths more RESTy
def lambda_handler(event:, context:)
  setup_variables

  log "event: #{JSON.generate(event)}"
  log "context: #{JSON.generate(context.inspect)}"

  # TODO: Clean this up, route properly
  # Check if /getphotos or /addphoto
  path_name = event["path"]
  if path_name == "/getphotos"
    get_photos(event)
  elsif path_name == "/addphoto" || event["image"]
    add_photo(event)
  else
    # TODO: Return a better response
    "No method by that name"
  end
end

def get_photos(event)
  return "No results" if event["queryStringParameters"].nil?

  images_hash = []
  from_number = event["queryStringParameters"]["from_number"]

  if from_number
    @s3.bucket(@s3_bucket_name).objects(prefix: @s3_prefix).each do |object|
      # TODO: Make loosely 'equal' instead of 'include?'
      # TODO: Add food metadata to object metadata
      # 'loosely' because we don't want the user to enter in the prefix/country code every time "+1"/etc
      if object.key.include?(from_number)
        images_hash.push(
          {
            key: object.key,
            public_url: object.public_url,
            last_modified: object.last_modified
          }
        )
      end
    end

    # @s3_client = Aws::S3::Client.new(region: @region_name)
    # s3_options = {
    #   bucket: @s3_bucket_name, # required
    #   prefix: "#{@s3_prefix}#{from_number}/",
    # }
    # resp = @s3_client.list_objects_v2(s3_options)
    # log "resp.contents.to_json: #{resp.contents.to_json}"
    # log "images_hash: #{images_hash}"
    #
    {
      "statusCode": 200,
      "headers": {
        "Access-Control-Allow-Origin": "*", # Required for CORS support to work
        "Access-Control-Allow-Credentials": true # Required for cookies, authorization headers with HTTPS
      },
      "body": JSON.generate(images_hash),
      "isBase64Encoded": false
    }
  end
end

# TODO: Refactor all the things, aka cleanup
def add_photo(event)
  from_number = event["fromNumber"]
  message = event["body"]
  pic_url = event["image"]
  num_media = event["numMedia"]

  twilio_resp = "No image found, try sending in some food!"

  # Check if we have their number
  params = {
    table_name: @dynamodb_table_name,
    key_condition_expression: "#fn = :from_number",
    expression_attribute_names: {
      "#fn" => "fromNumber"
    },
    expression_attribute_values: {
      ":from_number" => from_number
    }
  }

  response_dynamo = @dynamodb.query(params)
  log "response_dynamo: #{response_dynamo.inspect}"
  if response_dynamo.count.zero?
    if message.length.zero?
      return "What is your name?"
    else
      put_item(from_number, message)
      return "We've added you to the system! Snap away."
    end
  end

  if num_media != '0'
    file_name = SecureRandom.hex(10)
    # get photo from s3
    _image = download_image(pic_url, file_name)

    # Add to S3 Bucket
    key = @s3_prefix + from_number.tr("+", "") + "/" + file_name + ".png"
    _s3_file_url = upload_to_s3(@s3_bucket_name, key, "/tmp/#{file_name}")

    twilio_resp = "Hi, here's your link: http://www.quicktrack.pro?num=#{from_number}"
  end

  # { statusCode: 200, body: JSON.generate({ message: twilio_resp }) }
  twilio_resp
rescue Exception => e
  log e.message
end
