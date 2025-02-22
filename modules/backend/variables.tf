variable "cname" {
  type        = string
  description = "the cname for the website hosting the resume (eg www)"
}

variable "domain_name" {
  type        = string
  description = "The domain name for the cloud resume website"
}

variable "dynamodb_table_name" {
  type        = string
  description = "The table name in DynamoDB that stores the visitor count"
}