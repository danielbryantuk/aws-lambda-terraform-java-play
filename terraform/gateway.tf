resource "aws_api_gateway_rest_api" "hello_world_api" {
  name        = "hello_world_api"
  description = "Hello, world API"
}

resource "aws_api_gateway_resource" "hello_world_api_gateway" {
  rest_api_id = "${aws_api_gateway_rest_api.hello_world_api.id}"
  parent_id   = "${aws_api_gateway_rest_api.hello_world_api.root_resource_id}"
  path_part   = "${var.api_path}"
}

resource "aws_api_gateway_method" "hello_world_method" {
  rest_api_id   = "${aws_api_gateway_rest_api.hello_world_api.id}"
  resource_id   = "${aws_api_gateway_resource.hello_world_api_gateway.id}"
  http_method   = "${var.hello_world_http_method}"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "hello_world_integration" {
  rest_api_id             = "${aws_api_gateway_rest_api.hello_world_api.id}"
  resource_id             = "${aws_api_gateway_resource.hello_world_api_gateway.id}"
  http_method             = "${aws_api_gateway_method.hello_world_method.http_method}"
  integration_http_method = "${aws_api_gateway_method.hello_world_method.http_method}"
  type                    = "AWS"
  uri                     = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/arn:aws:lambda:${var.region}:${var.account_id}:function:${aws_lambda_function.hello_world_function.function_name}/invocations"
  credentials             = "arn:aws:iam::${var.account_id}:role/${aws_iam_role.lambda_apigateway_iam_role.name}"
}

resource "aws_api_gateway_method_response" "OK" {
  rest_api_id = "${aws_api_gateway_rest_api.hello_world_api.id}"
  resource_id = "${aws_api_gateway_resource.hello_world_api_gateway.id}"
  http_method = "${aws_api_gateway_method.hello_world_method.http_method}"

  response_models = {
    "application/json" = "Empty"
  }

  status_code = "200"
}

resource "aws_api_gateway_integration_response" "hello_world_integration_response" {
  depends_on  = [aws_api_gateway_integration.hello_world_integration]
  rest_api_id = "${aws_api_gateway_rest_api.hello_world_api.id}"
  resource_id = "${aws_api_gateway_resource.hello_world_api_gateway.id}"
  http_method = "${aws_api_gateway_method.hello_world_method.http_method}"
  status_code = "${aws_api_gateway_method_response.OK.status_code}"
}

resource "aws_api_gateway_deployment" "hello_world_deploy" {
  depends_on  = [aws_api_gateway_integration.hello_world_integration]
  stage_name  = "${var.api_env_stage_name}"
  rest_api_id = "${aws_api_gateway_rest_api.hello_world_api.id}"
}
