resource "aws_lambda_function" "quicksight_lambda" {
  filename      = "lambda_function.zip" # Você deve zipar seu código python antes
  function_name = "get_quicksight_url"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"

  environment {
    variables = {
      DASHBOARD_ID = var.dashboard_id
      ACCOUNT_ID   = var.account_id
      USER_ARN     = var.quicksight_user_arn
    }
  }
}