# hello-sam

A simple .NET 8 "hello world" serverless app, deployed as a **single SAM stack**:

- A static **frontend** (HTML/CSS/JS) served from **S3** static website hosting.
- A **.NET 8 Lambda** running on `provided.al2023` as a self-contained
  executable (`bootstrap`), exposed through **API Gateway** at `GET /hello?name=…`.

The frontend's JavaScript calls the API Gateway endpoint (CORS-enabled) and
displays the greeting.

## Prerequisites

- .NET 8 SDK (`dotnet` on your `PATH`)
- AWS SAM CLI (`sam`)
- `make` (used by SAM's `makefile` build method)
- Docker — only required for `sam local`
- AWS credentials in `~/.aws/credentials` — only required for `sam deploy`

## Local development

### 1. Build

```bash
sam build
```

This runs `dotnet publish` (via `src/HelloWorld/Makefile`) and produces the
deployable artifact in `.aws-sam/build/HelloWorldFunction/`.

### 2. Validate the template

```bash
sam validate --region us-east-1
```

### 3. Run locally

Start the API locally (emulates API Gateway + Lambda; needs Docker):

```bash
sam local start-api
# then: curl "http://localhost:3000/hello?name=Ada"
```

Or invoke the function directly with a payload:

```bash
sam local invoke HelloWorldFunction -e events/event.json
```

## Deploy to AWS

### First time (guided)

```bash
sam deploy --guided
```

This prompts for a stack name and region and writes a `samconfig.toml`, so later
deploys are just `sam deploy`.

### Non-interactive

```bash
sam deploy \
  --region us-east-1 \
  --stack-name hello-sam \
  --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM \
  --resolve-s3
```

- `--resolve-s3` lets SAM create/manage its own artifact bucket automatically.
- `CAPABILITY_NAMED_IAM` is required because the template defines an IAM role
  with a fixed name (`EC2LabRole`).

### IAM execution role

The function needs an IAM **execution role** with two parts:

1. **Trust policy** — allows Lambda to assume the role:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": { "Service": "lambda.amazonaws.com" },
      "Action": "sts:AssumeRole"
    }
  ]
}
```

2. **Permissions policy** — grants the function what it needs. At minimum it
   writes logs to CloudWatch; use the managed
   `AWSLambdaBasicExecutionRole` (or the equivalent inline policy):

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "*"
    }
  ]
}
```

The template defines this role explicitly as an `AWS::IAM::Role` resource named
`EC2LabRole` (see `template.yaml`), with the trust policy and inline permissions
above. Because it uses a fixed `RoleName`, deploys need the `CAPABILITY_NAMED_IAM`
capability. To let SAM create an auto-named role instead, delete the
`ExecutionRole` resource and the `Role:` line on the function.

## Test the deployed app

After deploy, get the endpoint URLs and query them:

```bash
aws cloudformation describe-stacks --stack-name hello-sam \
  --query "Stacks[0].Outputs[?OutputKey=='HelloWorldApi'].OutputValue" --output text
aws cloudformation describe-stacks --stack-name hello-sam \
  --query "Stacks[0].Outputs[?OutputKey=='WebsiteUrl'].OutputValue" --output text
```

Open the **WebsiteUrl** in a browser (the UI), or query the API directly:

```bash
curl "https://<api-id>.execute-api.us-east-1.amazonaws.com/Prod/hello?name=Ada"
# => {"Message":"Hello, Ada!"}
```

Or invoke the Lambda directly (no URL needed):

```bash
aws lambda invoke \
  --function-name hello-world-dotnet \
  --payload '{"queryStringParameters":{"name":"Ada"}}' \
  --cli-binary-format raw-in-base64-out /tmp/out.json && cat /tmp/out.json
```

## Clean up

```bash
sam delete --stack-name hello-sam --region us-east-1
```

## Project layout

```
src/HelloWorld/          Lambda function (custom runtime, self-contained bootstrap)
src/HelloWorld/Makefile  sam build target for dotnet publish
src/SiteUploader/        Frontend (index.html) + custom-resource Lambda that
                         uploads it to the S3 bucket during sam deploy
src/WebFrontend/         Optional Dockerless browser front-end (dev convenience)
events/event.json        Sample API Gateway proxy event for sam local invoke
template.yaml            SAM template (S3 + API Gateway + Lambda)
```

> `src/WebFrontend` and `scripts/*.sh` are a Dockerless local-development
> convenience that proxy to the Lambda Runtime Interface Emulator. With SAM
> installed, `sam local start-api` replaces them.
