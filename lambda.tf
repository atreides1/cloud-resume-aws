# setup for lambda: src files as zip, permissions policies, execution role
data "archive_file" "get_visitor_count_lambda_payload" {
  type       = "zip"
  source_dir = "${path.module}/lambda-src"
  excludes = [
    "venv",
    "_pycache_"
  ]
  output_path = "${path.module}/payload.zip"
}

# create lambda execution role
resource "aws_iam_role" "get_visitor_count_role" {
  name               = "get_visitor_count_role"
  assume_role_policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "lambda.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
  }
  EOF
  tags = {
    Project = "CloudResumeChallenge"
  }
}
# permission policies
resource "aws_iam_policy" "visitor_counter_table_rw" {
  name        = "visitor-counter-rw-policy"
  description = "Gives read and write access to ${var.dynamodb_table_name} table in DynamoDB"

  policy = <<EOT
  {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "ReadWriteTable",
            "Effect": "Allow",
            "Action": [
                "dynamodb:BatchGetItem",
                "dynamodb:GetItem",
                "dynamodb:Query",
                "dynamodb:Scan",
                "dynamodb:BatchWriteItem",
                "dynamodb:PutItem",
                "dynamodb:UpdateItem"
            ],
            "Resource": "${aws_dynamodb_table.visitor_counter.arn}"
        },
        {
            "Sid": "GetStreamRecords",
            "Effect": "Allow",
            "Action": "dynamodb:GetRecords",
            "Resource": "${aws_dynamodb_table.visitor_counter.arn}/stream/* "
        },
        {
            "Sid": "WriteLogStreamsAndGroups",
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "*"
        },
        {
            "Sid": "CreateLogGroup",
            "Effect": "Allow",
            "Action": "logs:CreateLogGroup",
            "Resource": "*"
        }
    ]
  }
  EOT
  tags = {
    Project = "CloudResumeChallenge"
  }
}

# attach policy to iam role
resource "aws_iam_role_policy_attachment" "visitor_counter" {
  role       = aws_iam_role.get_visitor_count_role.name
  policy_arn = aws_iam_policy.visitor_counter_table_rw.arn
}

# create the lambda function
resource "aws_lambda_function" "get_visitor_count" {
  filename         = data.archive_file.get_visitor_count_lambda_payload.output_path
  function_name    = "get_visitor_count"
  handler          = "lambda_function.lambda_handler"
  role             = aws_iam_role.get_visitor_count_role.arn
  runtime          = "python3.13"
  source_code_hash = data.archive_file.get_visitor_count_lambda_payload.output_base64sha256

  environment {
    variables = {
      DYNAMODB_TABLE_NAME = var.dynamodb_table_name
    }
  }
  tags = {
    Project = "CloudResumeChallenge"
  }
}

# allow api-gateway to invoke function
resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_visitor_count.function_name
  principal     = "apigateway.amazonaws.com"
}