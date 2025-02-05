terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.region
}

# AWS using us-east-1 so cloudfront can find the SSL cert
provider "aws" {
  region = "us-east-1"
  alias = "us-east-1"
}
