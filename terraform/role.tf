resource "aws_iam_role" "lambda_role" {
  name = "role-quicksight-lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy" "quicksight_policy" {
  name = "quicksight_embed_policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "quicksight:GenerateEmbedUrlForRegisteredUser"
        Effect   = "Allow"
        Resource = [
          "arn:aws:quicksight:${var.aws_region}:${var.account_id}:dashboard/${var.dashboard_id}",
          "${var.quicksight_user_arn}"
        ]
      },
      {
        Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
        Effect   = "Allow"
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}