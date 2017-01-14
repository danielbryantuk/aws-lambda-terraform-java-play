provider "aws" {
    access_key = "${var.aws_access_key}"
    secret_key = "${var.aws_secret_key}"
    region = "${var.region}"
}

resource "aws_iam_role" "iam_for_lambda" {
    name = "iam_for_lambda"
    assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
}

resource "aws_lambda_function" "hello_world_java" {
    filename = "${var.lambda_payload_filename}"
    function_name = "hello_world_java"
    role = "${aws_iam_role.iam_for_lambda.arn}"
    handler = "uk.co.danielbryant.exp.helloworld.Hello"
    source_code_hash = "${base64sha256(file(var.lambda_payload_filename))}"
    runtime = "java8"
    environment {
        variables = {
            from = "London"
        }
    }
}

resource "aws_api_gateway_resource" "hello_world_api_gateway" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  parent_id = "${aws_api_gateway_rest_api.api.root_resource_id}"
  path_part = "mydemoresource"
}

resource "aws_api_gateway_rest_api" "api" {
  name = "myapi"
}

resource "aws_api_gateway_method" "method" {
  rest_api_id   = "${aws_api_gateway_rest_api.api.id}"
  resource_id   = "${aws_api_gateway_rest_api.api.root_resource_id}"
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "integration" {
  rest_api_id             = "${aws_api_gateway_rest_api.api.id}"
  resource_id             = "${aws_api_gateway_rest_api.api.root_resource_id}"
  http_method             = "${aws_api_gateway_method.method.http_method}"
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${aws_lambda_function.hello_world_java.arn}/invocations"
}

resource "aws_lambda_permission" "hello_world_java" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.hello_world_java.arn}"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.region}:${var.account_id}:${aws_api_gateway_rest_api.api.id}/*/${aws_api_gateway_method.method.http_method}/"
}

resource "aws_api_gateway_deployment" "test_deploy" {
  depends_on  = ["aws_api_gateway_integration.integration"]
  stage_name  = "beta"
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
}

output "path" {
  value = "${aws_api_gateway_resource.hello_world_api_gateway.path}"
}
