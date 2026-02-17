# URL do Front-end (CloudFront)
output "cloudfront_url" {
  description = "URL para acessar o dashboard via CloudFront"
  value       = "https://${aws_cloudfront_distribution.s3_distribution.domain_name}/index.html"
}

# Endpoint da API Gateway
output "api_gateway_url" {
  description = "Endpoint da API para solicitar a Embed URL"
  value       = "${aws_apigatewayv2_stage.default_stage.invoke_url}/get-url"
}

# Nome do Bucket S3 (Útil para comandos de sync/upload)
output "s3_bucket_name" {
  description = "Nome do bucket onde você deve subir o index.html"
  value       = aws_s3_bucket.frontend_bucket.id
}

# ID da Distribuição do CloudFront (Útil para criar invalidações de cache)
output "cloudfront_distribution_id" {
  description = "ID da distribuição para realizar invalidações (cache)"
  value       = aws_cloudfront_distribution.s3_distribution.id
}

# Output para facilitar a configuração do HTML
output "cognito_login_url" {
  value = "https://${aws_cognito_user_pool_domain.main.domain}.auth.${var.aws_region}.amazoncognito.com/login?client_id=${aws_cognito_user_pool_client.client.id}&response_type=token&scope=email+openid+profile&redirect_uri=https://dash.vpaulo.com/index.html"
}