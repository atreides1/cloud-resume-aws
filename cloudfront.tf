resource "aws_acm_certificate" "cloud_resume_cert" {
  provider = aws.us-east-1
  domain_name       = "${var.domain_name}"
  validation_method = "DNS"
    subject_alternative_names = ["*.${var.domain_name}", "${var.domain_name}"]

  lifecycle {
    create_before_destroy = true
  }
  tags = {
      Project = "CloudResumeChallenge"
    }
}

resource "aws_route53_record" "ssl_cert_validation_records" {
  for_each = {
    for dvo in aws_acm_certificate.cloud_resume_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = var.route53_hosting_zone_id
}

resource "aws_acm_certificate_validation" "example" {
  provider = aws.us-east-1
  certificate_arn         = aws_acm_certificate.cloud_resume_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.ssl_cert_validation_records : record.fqdn]
}

# create CloudFront distribution
resource "aws_cloudfront_origin_access_control" "cloud_resume" {
  name                              = "CloudFront S3 OAC"
  description                       = "access for cloud resume files in s3"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "cloud_resume" {
  enabled             = true
  default_root_object = "index.html"
  aliases = ["newresume.${var.domain_name}"]

  origin {
    domain_name              = "${var.bucket_name}.s3.${var.region}.amazonaws.com"
    origin_id                = aws_s3_bucket.cloud_resume.id
    origin_access_control_id = aws_cloudfront_origin_access_control.cloud_resume.id
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_s3_bucket.cloud_resume.id
    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  price_class = "PriceClass_200"

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US", "CA"]
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = false
    acm_certificate_arn = aws_acm_certificate.cloud_resume_cert.arn
    ssl_support_method = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  tags = {
      Project = "CloudResumeChallenge"
    }
}

resource "aws_route53_record" "cloudfront_cname" {

  allow_overwrite = true
  name            = "newresume"
  records         = [aws_cloudfront_distribution.cloud_resume.domain_name]
  ttl             = 60
  type            = "CNAME"
  zone_id         = var.route53_hosting_zone_id
}
