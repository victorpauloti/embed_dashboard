
# CloudFront OAC
resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "s3-quicksight-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# CloudFront Distribution
resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name              = aws_s3_bucket.frontend_bucket.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
    origin_id                = "S3Origin"
  }

  #price_class = "Free plan"
  enabled             = true # (Required) - Whether the distribution is enabled to accept end user requests for content.
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3Origin"

    forwarded_values {
      query_string = false
      cookies { forward = "none" }
    }

    viewer_protocol_policy = "redirect-to-https"
  }

  # search code country restriction --> https://www.iso.org/obp/ui/#home
  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["BR","DE"] # Permitir acesso apenas do Brasil
    }
  }

    viewer_certificate {
    cloudfront_default_certificate = true
  }

  # if custon domain is used, ACM certificate must be added
  # viewer_certificate {
  #   acm_certificate_arn = var.acm_certificate_arn
  #   minimum_protocol_version = "TLSv1.2_2021"
  #   ssl_support_method  = "sni-only"
  # }

   # 1. Add your custom domain(s) to the 'aliases' list
  #aliases = ["custon-domain.com"] # Substitua pelo seu domínio personalizado

}

