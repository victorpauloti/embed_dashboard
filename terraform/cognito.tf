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
  # email_verification_message = "Seu código de verificação é {####}"
  # email_verification_subject = "Verifique seu email para acessar o Dashboard"

  admin_create_user_config {
  allow_admin_create_user_only = true # Somente admins podem criar usuários (ex: via CLI ou Console)

  }

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
  callback_urls = ["https://dash.vpaulo.com/index.html"]
  logout_urls   = ["https://dash.vpaulo.com/index.html"]

  explicit_auth_flows = [
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_CUSTOM_AUTH"
  ]
}

# resource "aws_cognito_user_group" "main" {
#   name         = "user-group"
#   user_pool_id = aws_cognito_user_pool.pool.id
#   description  = "Managed by Terraform"
#   precedence   = 42
#   #role_arn     = aws_iam_role.group_role.arn
# }