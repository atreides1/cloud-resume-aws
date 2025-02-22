# AWS using us-east-1 so CloudFront can find the SSL cert
provider "aws" {
  region = "us-east-1"
  alias  = "us-east-1"
}