resource "aws_apigatewayv2_api" "http" {
  name          = "getVisitorCount-API"
  protocol_type = "HTTP"
  cors_configuration {
    allow_origins = ["https://${var.cname}.${var.domain_name}"]
  }
  tags = {
    Project = "CloudResumeChallenge"
  }
}

# integration with lambda
resource "aws_apigatewayv2_integration" "lambda" {
  api_id           = aws_apigatewayv2_api.http.id
  integration_type = "AWS_PROXY"

  connection_type        = "INTERNET"
  description            = "Lambda example"
  integration_method     = "POST"
  integration_uri        = aws_lambda_function.get_visitor_count.invoke_arn
  passthrough_behavior   = "WHEN_NO_MATCH"
  payload_format_version = "2.0"
}

# stage
resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.http.id
  name        = "$default"
  auto_deploy = true
}
# routes
resource "aws_apigatewayv2_route" "lambda_invoke" {
  api_id    = aws_apigatewayv2_api.http.id
  route_key = "ANY /getVisitorCount"
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}
