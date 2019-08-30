#!/usr/bin/env bash

# Source all of the ENV variables from ".env" in the root directory to use in this script
# https://stackoverflow.com/a/30969768/1119513
set -a
source "$pwd.env"
set +a

LAMBDA_ZIP="fileb://${pwd}dist/lambda_function.zip"
RUBY_GEMS_ZIP="fileb://${pwd}dist/ruby-gems.zip"

# r - recursive
# 9 - compression level
# q - quiet
zip -9q dist/lambda_function.zip .env lambda_function.rb dist/packaged-template.yaml sam/template.yaml
zip -r9q dist/ruby-gems.zip ./ruby/

aws s3 cp --region us-east-1 dist/lambda_function.zip s3://www.quicktrack.pro/lambda_function.zip
aws s3 cp --region us-east-1 index.html s3://www.quicktrack.pro/index.html

echo "Updating layer..."
# Strip quotes from lambda ARN because why not add another layer of complexity
# This is what the 'tr' function is doing at the end of the line
LAYER_VERSION_ARN=$(aws lambda publish-layer-version --layer-name "QuickTrackLambdaLayer" --zip-file "$RUBY_GEMS_ZIP" --compatible-runtimes ruby2.5 --query "LayerVersionArn" | tr -d \")

echo "LAYER_VERSION_ARN: $LAYER_VERSION_ARN"

echo "Updating function configuration..."
aws lambda update-function-configuration --function-name "QuickTrackStack-QuickTrackLambda-$FUNCTION_ID" --layers $LAYER_VERSION_ARN --query "Version"

echo "Updating function code..."
aws lambda update-function-code --function-name "QuickTrackStack-QuickTrackLambda-$FUNCTION_ID" --zip-file "$LAMBDA_ZIP" --publish --query "Version"
