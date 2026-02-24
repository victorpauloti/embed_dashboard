resource "aws_apigatewayv2_api" "http_api" {
  name          = "quicksight-api"
  protocol_type = "HTTP"
  cors_configuration {
    allow_origins = ["https://${aws_cloudfront_distribution.s3_distribution.domain_name}", "https://dash.vpaulo.com"]
    allow_methods = ["GET"] # Apenas GET para a rota /get-url ,"OPTIONS"
    allow_headers = ["content-type" , "authorization"] # Permitir o header Authorization para o token JWT
    max_age       = 300
  }
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id           = aws_apigatewayv2_api.http_api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.quicksight_lambda.invoke_arn
}

#  Cria o Autorizador do Cognito para a HTTP API
resource "aws_apigatewayv2_authorizer" "cognito_auth" {
  api_id           = aws_apigatewayv2_api.http_api.id
  authorizer_type  = "JWT"
  identity_sources = ["$request.header.Authorization"]
  name             = "cognito-authorizer"

  jwt_configuration {
    audience = [aws_cognito_user_pool_client.client.id]
    issuer   = "https://${aws_cognito_user_pool.pool.endpoint}"
  }
}

#  Atualiza a Rota para usar o Autorizador
resource "aws_apigatewayv2_route" "get_url_route" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "GET /get-url"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"

  # Adicione a autorização JWT do Cognito
  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.cognito_auth.id
}

resource "aws_apigatewayv2_stage" "default_stage" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.quicksight_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*/get-url"
}

resource "aws_api_gateway_domain_name" "example" {
  domain_name              = "api.vpaulo.com"
  regional_certificate_arn = "arn:aws:acm:us-east-1:555768437715:certificate/d6b3320a-84e0-4258-8055-38821f9a5605"
  security_policy          = "SecurityPolicy_TLS13_1_3_2025_09"
  endpoint_access_mode     = "STRICT"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}


