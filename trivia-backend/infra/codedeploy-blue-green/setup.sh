#!/bin/bash

set -ex

# Provision infrastructure

npm install

npm run deploy-test-infra

npm run deploy-prod-infra

# Provision deployment hooks

cd hooks/

npm install

aws cloudformation package --template-file template.yaml --s3-bucket $1 --output-template-file packaged-template.yaml

aws cloudformation deploy --region ap-southeast-2 --template-file packaged-template.yaml --stack-name TriviaBackendHooksTest --capabilities CAPABILITY_IAM --parameter-overrides TriviaBackendDomain=api-test.fspike.com

aws cloudformation deploy --region ap-southeast-2 --template-file packaged-template.yaml --stack-name TriviaBackendHooksProd --capabilities CAPABILITY_IAM --parameter-overrides TriviaBackendDomain=api.fspike.com

cd ..

# Generate config files

mkdir -p build

export AWS_REGION=ap-southeast-2

node produce-config.js -g test -s TriviaBackendTest -h TriviaBackendHooksTest

node produce-config.js -g prod -s TriviaBackendProd -h TriviaBackendHooksProd

# Create ECS resources

ACCOUNT_ID=`aws sts get-caller-identity --query Account --output text --region ap-southeast-2`

sed -i "s|<PLACEHOLDER>|$ACCOUNT_ID.dkr.ecr.ap-southeast-2.amazonaws.com/reinvent-trivia-backend:latest|g" build/task-definition-test.json build/task-definition-prod.json

aws ecs create-cluster --region ap-southeast-2 --cluster-name default

aws ecs register-task-definition --region ap-southeast-2 --cli-input-json file://build/task-definition-test.json

aws ecs create-service --region ap-southeast-2 --service-name trivia-backend-test --cli-input-json file://build/service-definition-test.json

aws ecs register-task-definition --region ap-southeast-2 --cli-input-json file://build/task-definition-prod.json

aws ecs create-service --region ap-southeast-2 --service-name trivia-backend-prod --cli-input-json file://build/service-definition-prod.json

# Create CodeDeploy resources

aws deploy create-application --region ap-southeast-2 --application-name AppECS-default-trivia-backend-test --compute-platform ECS

aws deploy create-application --region ap-southeast-2 --application-name AppECS-default-trivia-backend-prod --compute-platform ECS

aws deploy create-deployment-group --region ap-southeast-2 --deployment-group-name DgpECS-default-trivia-backend-test --cli-input-json file://build/deployment-group-test.json

aws deploy create-deployment-group --region ap-southeast-2 --deployment-group-name DgpECS-default-trivia-backend-prod --cli-input-json file://build/deployment-group-prod.json

# Start deployment

aws ecs deploy --region ap-southeast-2 --service trivia-backend-test --task-definition build/task-definition-test.json --codedeploy-appspec build/appspec-test.json

aws ecs deploy --region ap-southeast-2 --service trivia-backend-prod --task-definition build/task-definition-prod.json --codedeploy-appspec build/appspec-prod.json
