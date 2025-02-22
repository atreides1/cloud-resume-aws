import os
import json
import boto3
import pytest
from botocore.exceptions import ClientError
from moto import mock_aws

from lambda_function import LambdaDynamoDBClass
from lambda_function import update_visitor_count

@pytest.fixture()
def aws_credentials():
    """Mocked AWS Credentials for moto."""
    os.environ["AWS_ACCESS_KEY_ID"] = "testing"
    os.environ["AWS_SECRET_ACCESS_KEY"] = "testing"
    os.environ["AWS_SECURITY_TOKEN"] = "testing"
    os.environ["AWS_SESSION_TOKEN"] = "testing"
    os.environ['AWS_DEFAULT_REGION'] = 'us-east-1'
    os.environ["DYNAMODB_TABLE_NAME"] = "unit_test_ddb"

def test_get_count_table_with_entries(aws_credentials):
    with mock_aws():
        dynamodb = boto3.resource("dynamodb")
        table = dynamodb.create_table(
            TableName=os.environ["DYNAMODB_TABLE_NAME"],
            KeySchema=[{"AttributeName": "id", "KeyType": "HASH"}],
            AttributeDefinitions=[{"AttributeName": "id", "AttributeType": "S"}],
            BillingMode="PAY_PER_REQUEST",
        )
        table.wait_until_exists()

        mocked_dynamodb_resource = { "resource": boto3.resource("dynamodb"),
                                    "table_name": os.environ["DYNAMODB_TABLE_NAME"]}

        mocked_dynamodb_class = LambdaDynamoDBClass(mocked_dynamodb_resource)

        # Arrange data - add a new entry to table
        mocked_dynamodb_class.table.put_item(Item={"id": "1", "visitorCount": 1})

        # Act - call the update function
        count = update_visitor_count(mocked_dynamodb_class)
        # Assert - verify the data meets the expected result
        # in this case, the count should now be 2
        assert count == 2

def test_get_count_item_notfound() -> None:
    with mock_aws():
        dynamodb = boto3.resource("dynamodb")
        table = dynamodb.create_table(
            TableName=os.environ["DYNAMODB_TABLE_NAME"],
            KeySchema=[{"AttributeName": "id", "KeyType": "HASH"}],
            AttributeDefinitions=[{"AttributeName": "id", "AttributeType": "S"}],
            BillingMode="PAY_PER_REQUEST",
        )
        table.wait_until_exists()

        mocked_dynamodb_resource = { "resource": boto3.resource("dynamodb"),
                                    "table_name": os.environ["DYNAMODB_TABLE_NAME"]}

        mocked_dynamodb_class = LambdaDynamoDBClass(mocked_dynamodb_resource)

        # don't add any items to table, and try to update visitorCount
        # this should result in a "ValidationException"
        try:
            update_visitor_count(mocked_dynamodb_class)
        except ClientError as err:
            assert err.response["Error"]["Code"] == "ValidationException"
