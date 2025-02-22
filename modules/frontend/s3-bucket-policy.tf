#create bucket policy for CloudFront read access
resource "aws_s3_bucket_policy" "cloudfront_access" {
  bucket = aws_s3_bucket.cloud_resume.id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "AllowCloudFrontServicePrincipalReadOnly",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "cloudfront.amazonaws.com"
        },
        "Action" : "s3:GetObject",
        "Resource" : "arn:aws:s3:::${var.bucket_name}/*",
        "Condition" : {
          "StringEquals" : {
            "AWS:SourceArn" : aws_cloudfront_distribution.cloud_resume.arn
          }
        }
      }
    ]
  })
  depends_on = [aws_s3_bucket.cloud_resume, aws_cloudfront_distribution.cloud_resume]
}