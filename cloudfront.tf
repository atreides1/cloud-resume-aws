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
    cloudfront_default_certificate = true
  }

  tags = {
      Project = "CloudResumeChallenge"
    }
    depends_on = [ aws_s3_bucket.cloud_resume ]
}

# https://stackoverflow.com/questions/54303821/how-to-reference-a-resource-created-in-one-file-in-another-file-in-terraform

# resource "aws_acm_certificate" "cert-cloud-resume-site" {
#   domain_name       = "${var.domain_name}"
#   validation_method = "DNS"
#     subject_alternative_names = ["*.${var.domain_name}", "${var.domain_name}"]

#   lifecycle {
#     create_before_destroy = true
#   }
# tags = {
#       Project = "CloudResumeChallenge"
#     }
# }

# 3mM44WkB2CBKX2_UgHWBMrhykRYBWZ6wZWSod
# Q6hFheVykmt9YcfVW6kR6D

# resource "godaddy-dns_record" "cert-validation-cname" {
#   domain = "${var.domain_name}"
#   type   = "CNAME"
#   name   = "_sdfsdfsdf"
#   data   = "other.com"
# }


# resource "godaddy-dns_record" "cloudfront-connection" {
#   domain = "${var.domain_name}"
#   type   = "CNAME"
#   name   = "resume"
#   data   = "d2f0bqu02vdao1.cloudfront.net."
#   depends_on = [ 
#     # aws_s3_bucket_public_access_block.example
#    ]
# }