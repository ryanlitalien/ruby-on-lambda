#!/usr/bin/env bash

zip -9 dist/lambda_function.zip lambda_function.rb dist/packaged-template.yaml sam/template.yaml

aws s3 cp --region us-east-1 dist/lambda_function.zip s3://www.quicktrack.pro/lambda_function.zip
aws s3 cp --region us-east-1 index.html s3://www.quicktrack.pro/index.html

aws lambda update-function-code --function-name 'QuickTrackStack-QuickTrackLambda-VSH1KH3ITEJL' --zip-file fileb://${pwd}dist/lambda_function.zip --publish --query 'Version'
