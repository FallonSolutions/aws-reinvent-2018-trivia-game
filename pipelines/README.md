# Continuous delivery pipelines

This package uses the [AWS Cloud Development Kit (AWS)](https://github.com/awslabs/aws-cdk) to model AWS CodePipeline pipelines and to provision them with AWS CloudFormation.

In src/ directory:
* pipeline.ts: Generic pipeline class that defines an infrastructure-as-code pipeline
* api-base-image-pipeline.ts: Builds and publishes the base Docker image for the backend API service
* api-service-pipeline.ts: Builds and deploys the backend API service to Fargate
* static-site-pipeline.ts: Provisions infrastructure for the static site, like a CloudFront distribution and an S3 bucket, plus bundles and uploads the static site pages to the site's S3 bucket
* chat-bot-pipeline.ts: Builds and deploys the chat bot Lambda function and Lex model

In templates/ directory:
* trivia-backend-codedeploy-blue-green.template.yaml: Template for deploying the backend API service using CodeDeploy, instead of using CloudFormation for deployments.  This is an alternative to api-service-pipeline.ts listed above.

## Prep

Create a GitHub [personal access token](https://github.com/settings/tokens) with access to your fork of the repo, including "admin:repo_hook" and "repo" permissions.  Then store the token in Secrets Manager:

```
aws secretsmanager create-secret --region ap-southeast-2 --name TriviaGitHubToken --secret-string <my-github-personal-access-token>
```

## Customize

Replace all references to 'FallonSolutions' with your own fork of this repo.  Replace all references to 'fspike.com' with your own domain name.

## Deploy

Install the AWS CDK CLI: `npm i -g aws-cdk`

Install and build everything: `npm install && npm run build`

Then deploy the stacks:

```
cdk deploy --app 'node src/static-site-pipeline.js'

cdk deploy --app 'node src/api-base-image-pipeline.js'

cdk deploy --app 'node src/api-service-pipeline.js'

cdk deploy --app 'node src/chat-bot-pipeline.js'
```

To use CodeDeploy blue-green deployments instead of CloudFormation deployments for the API backend service, use the following instead of using the api-service-pipeline template listed above:

```
aws cloudformation deploy --region ap-southeast-2 --template-file templates/trivia-backend-codedeploy-blue-green.template.yaml --stack-name TriviaGameBackendPipeline --capabilities CAPABILITY_IAM
```

See the pipelines in the CodePipeline console.
