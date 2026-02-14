# randon pet
resource "random_pet" "bucket_name_generator" {
  prefix = "my-dashboard-quicksight-front"
  length = 2
}
# Bucket S3
resource "aws_s3_bucket" "frontend_bucket" {
  bucket = random_pet.bucket_name_generator.id
  force_destroy = true
}

# Bucket Policy para o OAC
resource "aws_s3_bucket_policy" "allow_cloudfront" {
  bucket = aws_s3_bucket.frontend_bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowCloudFrontServicePrincipal"
        Effect    = "Allow"
        Principal = { Service = "cloudfront.amazonaws.com" }
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.frontend_bucket.arn}/*"
        Condition = {
          ArnLike = { "AWS:SourceArn" = aws_cloudfront_distribution.s3_distribution.arn }
        }
      }
    ]
  })
}