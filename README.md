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

## Architecture Diagram

TODO

## Local Development

TODO

## Deploy

* Check into "master"
* Boom

## Deploy Steps
* `sh ./scripts/create_lambda_package.sh`

### Links

* [AWS Lambda Layers documentation](https://docs.aws.amazon.com/lambda/latest/dg/configuration-layers.html)
* [AWS Ruby on Lambda announcement with code](https://aws.amazon.com/blogs/compute/announcing-ruby-support-for-aws-lambda/)
* [Getting started with AWS Lambda (Python) + Amazon API Gateway](https://github.com/aws-samples/lambda-apigateway-twilio-tutorial)
