#!/usr/bin/env bash

bundle install
bundle install --deployment
#gem pristine --all
#bundle install --deployment --path=.

# Package up the SAM template, upload into S3 bucket
sam package --template-file sam/template.yaml \
--output-template-file dist/packaged-template.yaml \
--s3-bucket www.quicktrack.pro

#./.bundle/
zip -9q dist/lambda_function.zip .env lambda_function.rb dist/packaged-template.yaml sam/template.yaml
zip -r9q dist/ruby-gems.zip ./ruby/

# Copy files up to S3 (note the --recursive flag)
aws s3 cp --region us-east-1 index.html s3://www.quicktrack.pro/index.html
aws s3 cp --region us-east-1 css/ s3://www.quicktrack.pro/css/ --recursive
aws s3 cp --region us-east-1 images/ s3://www.quicktrack.pro/images/ --recursive
aws s3 cp --region us-east-1 dist/lambda_function.zip s3://www.quicktrack.pro/lambda_function.zip
aws s3 cp --region us-east-1 dist/ruby-gems.zip s3://www.quicktrack.pro/ruby-gems.zip

sam deploy --template-file dist/packaged-template.yaml \
--stack-name QuickTrackStack \
--capabilities CAPABILITY_IAM
