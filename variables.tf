variable "bucket_name" {
  type = string
  default = "mb-cloud-resume-terraform-test2"
  description = "Name for the s3 bucket that stores the website resources"
}

variable "region" {
    type = string
    default = "us-west-2"
    description = "A valid AWS region (eg us-east-1)"
}
