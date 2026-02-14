variable "aws_region" {
  description = "Região da AWS onde os recursos serão criados"
  type        = string
  default     = "us-east-1"
}

variable "account_id" {
  description = "ID da conta AWS (12 dígitos)"
  type        = string
  # Validação simples para garantir que são apenas números e tem 12 dígitos
  validation {
    condition     = can(regex("^\\d{12}$", var.account_id))
    error_message = "O account_id deve conter exatamente 12 dígitos numéricos."
  }
}

variable "quicksight_user_arn" {
  description = "ARN do usuário registrado no QuickSight"
  type        = string
  sensitive   = true # Oculta o valor nos logs do Terraform (camada extra de proteção)
}

variable "dashboard_id" {
  description = "UUID do Dashboard do QuickSight"
  type        = string
}

variable "acm_certificate_arn" {
  description = "ARN do certificado ACM para o domínio personalizado do CloudFront"
  type        = string
  
}