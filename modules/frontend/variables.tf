variable "api_endpoint" {
  type = string
  description = "the API Gateway endpoint URL"
}

variable "bucket_name" {
  type        = string
  description = "Name for the s3 bucket that stores the website resources"
}

variable "cname" {
  type        = string
  description = "the cname for the website hosting the resume (eg www)"
}

variable "domain_name" {
  type        = string
  description = "The domain name for the cloud resume website"
}

variable "region" {
  type        = string
  description = "A valid AWS region (eg us-east-1)"
}

variable "route53_hosting_zone_id" {
  type        = string
  description = "The ID of the hosting zone"
}