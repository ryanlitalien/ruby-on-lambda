# ruby-on-lambda

[https://github.com/ryanlitalien/ruby-on-lambda](https://github.com/ryanlitalien/ruby-on-lambda)

## Why

Why not? :)

I have been using lots of these technologies in different projects, but I wanted to show an example of all of them being
used within one clearly documented project. There will be a Medium article to go along with this as well. Essentially, 
this is an example serverless app that has automatic deployment using Github Actions serving up a static HTML page that
uses AWS Lambda to process images, DynamoDB to store information and Twilio to handle SMS/MMS.

## Cool tech stuff

* Ruby
* Vue.js
* GitHub Actions
* Twilio
* AWS Serverless using:
  * API Gateway
  * CloudFormation 
  * DynamoDB
  * Lambda
  * S3 

## Prerequisite Setup
* Buy domain name, setup DNS to point to AWS
* Bucket creation (see `config/s3-bucket-policy.json`)
* Point domains to buckets
* ...
* Run `./scripts/create_lambda_package.sh`
* Update `www.domain.name` bucket with updated policy
* Test via new domain name

## Architecture Diagram

TODO

## Local Development

* Update `scripts/update_lambda_package.sh` with correct URLs
* If modifying Ruby or HTML, run: `./scripts/update_lambda_package.sh`
* If modifying SAM or AWS, run: `./scripts/create_lambda_package.sh`

## Deploy

* Check into "master"
* Boom

## Actual Deploy Steps
* Github master kicks off Github Actions
* ...

### Links

* [AWS Lambda Layers documentation](https://docs.aws.amazon.com/lambda/latest/dg/configuration-layers.html)
* [AWS Ruby on Lambda announcement with code](https://aws.amazon.com/blogs/compute/announcing-ruby-support-for-aws-lambda/)
* [Getting started with AWS Lambda (Python) + Amazon API Gateway](https://github.com/aws-samples/lambda-apigateway-twilio-tutorial)
