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