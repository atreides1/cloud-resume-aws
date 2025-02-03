output "cloudfront_distribution_arn" {
  value = aws_cloudfront_distribution.cloud_resume.arn
  description = "the arn of the cloudfront distribution, used for the s3 bucket policy"
}

output "cloudfront_distribution_url" {
  value = aws_cloudfront_distribution.cloud_resume.domain_name
  description = "the domain name of the cloudfront distribution, used for the dns cname"
}

output "s3_bucket_id" {
    value = aws_s3_bucket.cloud_resume.id
    description = "the id of the s3 bucket used to store website resources"
}