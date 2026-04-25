import pytest
import boto3
from moto import mock_aws
from uuid import uuid4

CHATS_TABLE_NAME = "chats_mvp"
MESSAGES_TABLE_NAME = "chats_messages_mvp"


@pytest.fixture(scope="function")
def mock_dynamodb_table():
    """Fixture per creare tabelle DynamoDB mockate senza dati"""
    with mock_aws():
        dynamodb = boto3.resource("dynamodb", region_name="eu-south-1")
        
        # Tabella chats
        chats_table = dynamodb.create_table(
            TableName=CHATS_TABLE_NAME,
            KeySchema=[
                {"AttributeName": "chat_id", "KeyType": "HASH"}
            ],
            AttributeDefinitions=[
                {"AttributeName": "chat_id", "AttributeType": "S"},
                {"AttributeName": "user_id", "AttributeType": "S"}
            ],
            GlobalSecondaryIndexes=[
                {
                    "IndexName": "user_index",
                    "KeySchema": [
                        {"AttributeName": "user_id", "KeyType": "HASH"}
                    ],
                    "Projection": {"ProjectionType": "ALL"}
                }
            ],
            BillingMode="PAY_PER_REQUEST"
        )
        
        # Tabella messages
        messages_table = dynamodb.create_table(
            TableName=MESSAGES_TABLE_NAME,
            KeySchema=[
                {"AttributeName": "chat_id", "KeyType": "HASH"},
                {"AttributeName": "message_id", "KeyType": "RANGE"}
            ],
            AttributeDefinitions=[
                {"AttributeName": "chat_id", "AttributeType": "S"},
                {"AttributeName": "message_id", "AttributeType": "S"}
            ],
            BillingMode="PAY_PER_REQUEST"
        )
        
        yield {
            "chats": chats_table,
            "messages": messages_table,
            "dynamodb": dynamodb,
            "chats_table_name": CHATS_TABLE_NAME,
            "messages_table_name": MESSAGES_TABLE_NAME
        }