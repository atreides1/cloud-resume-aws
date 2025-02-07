resource "aws_dynamodb_table" "visitor_counter" {
  name         = var.dynamodb_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Project = "CloudResumeChallenge"
  }
}

resource "aws_dynamodb_table_item" "visitor_counter" {
  table_name = aws_dynamodb_table.visitor_counter.name
  hash_key   = aws_dynamodb_table.visitor_counter.hash_key

  item = <<ITEM
    {
        "id" : {"S": "1"},
        "visitorCount": {"N" : "0"}
    }
    ITEM
}