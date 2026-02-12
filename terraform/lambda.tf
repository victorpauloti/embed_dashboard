# Isso cria o ZIP automaticamente a partir da pasta src
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/../src/lambda_function.py"
  output_path = "${path.module}/lambda_function.zip"
}

resource "aws_lambda_function" "quicksight_lambda" {
  # O Terraform agora usa o arquivo gerado acima
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  
  function_name    = "get_quicksight_url"
  role             = aws_iam_role.lambda_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.14"

  environment {
    variables = {
      DASHBOARD_ID = var.dashboard_id
      ACCOUNT_ID   = var.account_id
      USER_ARN     = var.quicksight_user_arn
    }
  }
}