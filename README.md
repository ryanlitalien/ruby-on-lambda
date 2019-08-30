# ruby-on-lambda

[https://github.com/ryanlitalien/ruby-on-lambda](https://github.com/ryanlitalien/ruby-on-lambda)

## Why

Why not? :)

I have been using lots of these technologies in different projects, but I wanted to show an example of all of them being
used within one clearly documented project. There will be a Medium article to go along with this as well. Essentially, 
this is an example serverless app that has automatic deployment using Github Actions serving up a static HTML page that
uses Vue.js to call ApiGateway to calll Ruby on AWS Lambda to process images, DynamoDB to store information and Twilio to handle SMS/MMS.

## THE STACK

* Ruby
* Vue.js
* Webpacker
* Bash
* GitHub Actions
* Twilio
* AWS SAM (Serverless Application Model)
  * API Gateway
  * CloudFormation 
  * DynamoDB
  * Lambda
  * Lambda Layers
  * S3
  * IAM
  * awscli

## Assumptions

These aren't barriers, just assumptions as they're probably defaults

* You're using AWS Region `us-east-1`
* You're using your own AWS account
* You're adding a bucket outside of this process. Including a "long-living" bucket is a bad idea in the SAM stack.

## Prerequisite Setup

* Buy domain name, setup DNS to point to AWS
* Bucket creation (see `config/s3-bucket-policy.json`)
* Point domains to buckets
* Install `aws` cli via brew (or other package managers)
  * `brew install awscli` 
  * `aws --version` (_should be around version 1.16.170_)
  * You might need to setup your AWS credentials + config
    * `~/.aws/config`
    * `~/.aws/credentials`
* Open `sam/template.yaml` and other files and replace `QuickTrack` and associated URLs with your app name
* Run `./scripts/create_lambda_package.sh`
  * You should see `Successfully created/updated stack - QuickTrackStack`
  * and
  * `This is your new API URL!` with an AWS API Gateway URL
* Put your new API URL into `index.html`
* Update `www.domain.name` bucket policy with updated Lambda ARN
  * Example policy: `config/s3-bucket-policy.json`
  * You can find it in your new role: https://console.aws.amazon.com/iam/home?region=us-east-1#/roles
* Update `.env` with newly created IDs
  * `FUNCTION_ID` is the ID appended to your new lambda's name
  * Looks something like: `QuickTrackStack-QuickTrackLambda-2HH2H3HTLEU4O`
* Update `scripts/update_lambda_package.sh` with your domain
* Run `scripts/update_lambda_package.sh`
* Update the Twilio service URL
  * https://www.twilio.com/console/sms/services
  * -> YourMessagingService
  * -> Inbound Settings
  * -> Request URL
  * -> `https://<-your id->.execute-api.us-east-1.amazonaws.com/Prod/addphoto`
* Test your end to end by going to your website OR sending a text message to your Twilio SMS number.

## Architecture Diagram (in progress)

* << placeholder >>

## Local Development

* If modifying Ruby or HTML, run: `./scripts/update_lambda_package.sh`
* If modifying SAM or AWS, run: `./scripts/create_lambda_package.sh` (this should run an update if there are any changes)
* If adding or modifying gems, check the `scripts/create_lambda_package.sh` for bundle install commands

## Deploy (in progress)

* Check into "master"
* Boom 💥

## Actual Deploy Steps
* Commiting to master branch kicks off Github Actions workflow
* ...

## Vue.js
The Vue app is stored in the `site` directory and will be run at [http://localhost:3000/](http://localhost:3000/)

### To get started:
	yarn dev

### To build & start for production:
	yarn build
	yarn start

### To test:
	yarn test

## Connecting the dots & Testing

1. We should now have a publically accessible GET endpoint. Ex: `https://xxxx.execute-api.us-west-2.amazonaws.com/prod/addphoto`
2. Point your Twilio number to this endpoint. Recommend creating a Programmable SMS > Messaging Service (Inbound Settings > Request URL) and assigning it your Phone Number > Messaging > Messaging Service > `MESSAGING_SERVICE_NAME`.
3. The app should now be connected. Let's review: Twilio sends a GET request with MMS image, fromNumber and body to API Gateway. API Gateway transforms the GET request into a JSON object, which is passed to a Lambda function. Lambda processes the object and writes the user to DynamoDB and writes the image to S3. Lambda returns a string which API Gateway uses to create an XML object for Twilio's response to the user.
4. First, let's test the Lambda function. Click the Actions dropdown and Configure test event. We need to simulate the JSON object passed by API Gateway. Example:      
    ```
    {
      "body" : "hello",
      "fromNumber" : "+19145554224" ,
      "image" : "https://api.twilio.com/2010-04-01/Accounts/AC361180d5a1fc4530bdeefb7fbba22338/Messages/MM7ab00379ec67dd1391a2b13388dfd2c0/Media/ME7a70cb396964e377bab09ef6c09eda2a",
      "numMedia" : "1"
    }
    ```
    Click Test. At the bottom of the page you view Execution result and the log output in Cloudwatch logs. This is very helpful for debugging.  
5. Testing API Gateway requires a client that sends requests to the endpoint. I personally like the Chrome Extension [Advanced Rest Client](https://chrome.google.com/webstore/detail/advanced-rest-client/hgmloofddffdnphfgcellkdfbfbjeloo?hl=en-US) Send the endpoint a GET request and view its response. Ensure the S3 link works. You can also test by sending an MMS to phone number and checking the Twilio logs.

## Troubleshooting

1. Ensure your Lambda function is using the correct IAM role. The role must have the ability to write/read to DynamoDB and S3.
2. All Lambda interactions are logged in Cloudwatch logs. View the logs for debugging.
3. Lambda/API Gateway Forums

**Please Note:** Twilio is a 3rd party service that has terms of use that the user is solely responsible for complying with (https://www.twilio.com/legal/tos)

## Links

* [AWS Lambda Layers documentation](https://docs.aws.amazon.com/lambda/latest/dg/configuration-layers.html)
* [AWS Ruby on Lambda announcement with code](https://aws.amazon.com/blogs/compute/announcing-ruby-support-for-aws-lambda/)
* [Getting started with AWS Lambda (Python) + Amazon API Gateway](https://github.com/aws-samples/lambda-apigateway-twilio-tutorial)
* [Lambda Layers](https://medium.com/devopslinks/how-to-use-aws-lambda-layers-f4fe6624aff1)
* [Nokogiri w/Ruby Lambda issue fix - Github.com](https://github.com/stevenringo/lambda-ruby-pg-nokogiri)
* [Nokogiri w/Ruby Lambda issue fix - Medium.com](https://www.stevenringo.com/ruby-in-aws-lambda-with-postgresql-nokogiri/)
* [Using Ruby-Gems with Native Extensions on AWS Lambda](https://blog.francium.tech/using-ruby-gems-with-native-extensions-on-aws-lambda-aa4a3b8862c9)
* [Bundle issue](https://stackoverflow.com/questions/53634260/how-can-i-get-my-aws-lambda-to-access-gems-stored-in-vendor-bundle)
* [Adding CloudFront and Certificates Manually](https://medium.com/@maciejtreder/custom-domain-in-aws-api-gateway-a2b7feaf9c74)
* [Vuex explanation](https://medium.com/dailyjs/mastering-vuex-zero-to-hero-e0ca1f421d45)

## TODO

* Connect Github Actions so we can deploy automatically
* Fixup/refactor "inherited" Ruby syntax and design
* Probably should lock down the S3 policy a bit more
* Add nokogiri gem
* Add TwilioClient back to Lambda function (or remove completely)
* Convert inherited jQuery to Vue.js
  * Add Webpacker/VueCLI/etc.
* Fix the whole DynamoDB data storage concept
