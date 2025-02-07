import os
import json
import boto3

_LAMBDA_DYNAMODB_RESOURCE = { "resource" : boto3.resource('dynamodb'), 
                              "table_name" : os.environ.get("DYNAMODB_TABLE_NAME","visitor_counter") }
                              
# a global class for DynamoDB resources
class LambdaDynamoDBClass:
    def __init__(self, lambda_dynamodb_resource):
        self.resource = lambda_dynamodb_resource["resource"]
        self.table_name = lambda_dynamodb_resource["table_name"]
        self.table = self.resource.Table(self.table_name)

def update_visitor_count(dynamo_db : LambdaDynamoDBClass):
    print(dynamo_db.table_name)
    response = dynamo_db.table.update_item(
        Key={
            "id" : "1"
        },
        UpdateExpression="SET visitorCount = visitorCount + :n",
        ExpressionAttributeValues={
            ":n": 1,
        },
        ReturnValues="UPDATED_NEW",
    )
    return int(response["Attributes"]["visitorCount"])

def lambda_handler(event, context):
    global _LAMBDA_DYNAMODB_RESOURCE
    dynamodb_resource_class = LambdaDynamoDBClass(_LAMBDA_DYNAMODB_RESOURCE)

    visitorCount = update_visitor_count(dynamodb_resource_class)

    data = {
        "visitorCount": visitorCount
    }

    return {
        'statusCode': 200,
        'headers': {
            "Content-Type": "application/json",
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'OPTIONS,POST,GET'
        },
        'body': json.dumps(data)
    }