output "curl" {
  value = "curl -H 'Content-Type: application/json' -X POST -d '{\"name\": \"Daniel\"}' https://${aws_api_gateway_rest_api.hello_world_api.id}.execute-api.${var.region}.amazonaws.com/${aws_api_gateway_deployment.hello_world_deploy.stage_name}${aws_api_gateway_resource.hello_world_api_gateway.path}"
}
