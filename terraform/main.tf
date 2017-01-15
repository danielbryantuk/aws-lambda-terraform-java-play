provider "aws" {
    access_key = "${var.aws_access_key}"
    secret_key = "${var.aws_secret_key}"
    region = "${var.region}"
}

resource "aws_iam_role" "lambda_iam_role" {
    name = "lambda_iam_role"
    assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["apigateway.amazonaws.com","lambda.amazonaws.com"]
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy" "lambda_policy" {
    name   = "lambda_policy"
    role   = "${aws_iam_role.lambda_iam_role.id}"
    policy = <<POLICY
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
    },
    {
      "Effect": "Allow",
      "Action": [
        "lambda:InvokeFunction"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "cloudwatch:Describe*",
        "cloudwatch:Get*",
        "cloudwatch:List*"
      ],
      "Resource": "*"
    }
  ]
}
POLICY
}

resource "aws_lambda_function" "hello_world_java" {
    function_name = "hello_world_java"
    filename = "${var.lambda_payload_filename}"

    role = "${aws_iam_role.lambda_iam_role.arn}"
    handler = "uk.co.danielbryant.exp.helloworld.HelloLambdaHandler"
    source_code_hash = "${base64sha256(file(var.lambda_payload_filename))}"
    runtime = "java8"
    environment {
        variables = {
            currentLocation = "London"
        }
    }
}

resource "aws_lambda_permission" "hello_world_java" {
  statement_id = "AllowExecutionFromApiGateway"
  action = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.hello_world_java.function_name}"
  principal = "apigateway.amazonaws.com"
  source_arn = "arn:aws:execute-api:${var.region}:${var.account_id}:${aws_api_gateway_rest_api.hello_world_api.id}/${aws_api_gateway_deployment.hello_world_deploy.stage_name}/${aws_api_gateway_integration.hello_world_integration.integration_http_method}${aws_api_gateway_resource.hello_world_api_gateway.path}"
}

resource "aws_api_gateway_rest_api" "hello_world_api" {
  name = "hello_world_api"
  description = "Hello, world API"
}

resource "aws_api_gateway_resource" "hello_world_api_gateway" {
  rest_api_id = "${aws_api_gateway_rest_api.hello_world_api.id}"
  parent_id = "${aws_api_gateway_rest_api.hello_world_api.root_resource_id}"
  path_part = "helloworld"
}

resource "aws_api_gateway_method" "post_name_method" {
  rest_api_id = "${aws_api_gateway_rest_api.hello_world_api.id}"
  resource_id = "${aws_api_gateway_resource.hello_world_api_gateway.id}"
  http_method = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "hello_world_integration" {
  rest_api_id = "${aws_api_gateway_rest_api.hello_world_api.id}"
  resource_id = "${aws_api_gateway_resource.hello_world_api_gateway.id}"
  http_method = "${aws_api_gateway_method.post_name_method.http_method}"
  integration_http_method = "${aws_api_gateway_method.post_name_method.http_method}"
  type = "AWS"
  uri = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/arn:aws:lambda:${var.region}:${var.account_id}:function:${aws_lambda_function.hello_world_java.function_name}/invocations"
  credentials = "arn:aws:iam::${var.account_id}:role/${aws_iam_role.lambda_iam_role.name}"
}

resource "aws_api_gateway_method_response" "all_good" {
  rest_api_id = "${aws_api_gateway_rest_api.hello_world_api.id}"
  resource_id = "${aws_api_gateway_resource.hello_world_api_gateway.id}"
  http_method = "${aws_api_gateway_method.post_name_method.http_method}"
  response_models = {
    "application/json" = "Empty"
  }
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "hello_world_integration_response" {
  depends_on  = ["aws_api_gateway_integration.hello_world_integration"]
  rest_api_id = "${aws_api_gateway_rest_api.hello_world_api.id}"
  resource_id = "${aws_api_gateway_resource.hello_world_api_gateway.id}"
  http_method = "${aws_api_gateway_method.post_name_method.http_method}"
  status_code = "${aws_api_gateway_method_response.all_good.status_code}"
}

resource "aws_api_gateway_deployment" "hello_world_deploy" {
  depends_on  = ["aws_api_gateway_integration.hello_world_integration"]
  stage_name  = "beta"
  rest_api_id = "${aws_api_gateway_rest_api.hello_world_api.id}"
}

output "curl" {
  value = "curl -H 'Content-Type: application/json' -X POST -d '{\"name\": \"Daniel\"}' https://${aws_api_gateway_rest_api.hello_world_api.id}.execute-api.${var.region}.amazonaws.com/${aws_api_gateway_deployment.hello_world_deploy.stage_name}${aws_api_gateway_resource.hello_world_api_gateway.path}"
}
