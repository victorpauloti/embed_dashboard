# 1. User Pool: O banco de dados de usuários
resource "aws_cognito_user_pool" "pool" {
  name = "quicksight-user-pool"

  password_policy {
    minimum_length = 8
    require_lowercase = true
    require_numbers   = true
    require_symbols   = true
    require_uppercase = true
  }

  auto_verified_attributes = ["email"]
}

# 2. Domínio da Hosted UI (Escolha um prefixo único)
resource "aws_cognito_user_pool_domain" "main" {
  domain       = "vpaulo-dashboard-auth" # Troque por um nome exclusivo
  user_pool_id = aws_cognito_user_pool.pool.id
}

# 3. App Client: O "RG" da sua aplicação no Cognito
resource "aws_cognito_user_pool_client" "client" {
  name         = "quicksight-web-client"
  user_pool_id = aws_cognito_user_pool.pool.id

  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["code", "implicit"] # 'implicit' facilita para SPA simples
  allowed_oauth_scopes                 = ["email", "openid", "profile"]
  supported_identity_providers         = ["COGNITO"]

  # URLs de retorno (CloudFront)
  callback_urls = ["https://${aws_cloudfront_distribution.s3_distribution.domain_name}/index.html"]
  logout_urls   = ["https://${aws_cloudfront_distribution.s3_distribution.domain_name}/index.html"]

  explicit_auth_flows = [
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_CUSTOM_AUTH"
  ]
}

# Output para facilitar a configuração do HTML
output "cognito_login_url" {
  value = "https://${aws_cognito_user_pool_domain.main.domain}.auth.${var.aws_region}.amazoncognito.com/login?client_id=${aws_cognito_user_pool_client.client.id}&response_type=token&scope=email+openid+profile&redirect_uri=https://${aws_cloudfront_distribution.s3_distribution.domain_name}/index.html"
}