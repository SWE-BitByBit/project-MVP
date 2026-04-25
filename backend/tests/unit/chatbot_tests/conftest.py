import pytest
import boto3
from moto import mock_aws
from uuid import uuid4
from datetime import datetime, timezone
from unittest.mock import patch

from src.chatbot.adapters.dynamo_chat_adapter import DynamoChatAdapter
from src.chatbot.domain.chat import Chat
from src.chatbot.domain.chat_message import Message

# Costanti per i test
CHATS_TABLE_NAME = "chats_mvp"
MESSAGES_TABLE_NAME = "chats_messages_mvp"
TEST_USER_ID = str(uuid4())
TEST_CHAT_ID = str(uuid4())


@pytest.fixture(scope="function")
def mock_dynamodb():
    """Fixture per creare le tabelle DynamoDB mockate"""
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
            "dynamodb": dynamodb
        }


@pytest.fixture(scope="function")
def chat_adapter(mock_dynamodb):
    """Fixture per il DynamoChatAdapter"""
    return DynamoChatAdapter(dynamodb=mock_dynamodb["dynamodb"])


@pytest.fixture(scope="function")
def test_user_id():
    """Fixture per ID utente di test"""
    return TEST_USER_ID


@pytest.fixture(scope="function")
def test_chat_id():
    """Fixture per ID chat di test"""
    return TEST_CHAT_ID


@pytest.fixture(scope="function")
def sample_chat_data(mock_dynamodb, test_user_id, test_chat_id):
    """Fixture per inserire dati di test nelle tabelle"""
    chats_table = mock_dynamodb["chats"]
    messages_table = mock_dynamodb["messages"]
    
    # Inserisci una chat di esempio
    created_at = datetime.now(timezone.utc).isoformat()
    chats_table.put_item(
        Item={
            "chat_id": test_chat_id,
            "user_id": test_user_id,
            "title": "Test Chat",
            "created_at": created_at,
            "updated_at": created_at
        }
    )
    
    # Inserisci alcuni messaggi di esempio
    message_id_1 = str(uuid4())
    message_id_2 = str(uuid4())
    
    messages_table.put_item(
        Item={
            "chat_id": test_chat_id,
            "message_id": message_id_1,
            "text": "Hello, how are you?",
            "sender": "user",
            "created_at": created_at
        }
    )
    
    messages_table.put_item(
        Item={
            "chat_id": test_chat_id,
            "message_id": message_id_2,
            "text": "I'm doing great, thanks!",
            "sender": "ai",
            "created_at": created_at
        }
    )
    
    return {
        "chat_id": test_chat_id,
        "user_id": test_user_id,
        "message_ids": [message_id_1, message_id_2],
        "created_at": created_at
    }


@pytest.fixture(scope="function")
def sample_chat_object(sample_chat_data):
    """Fixture che restituisce un oggetto Chat per i test"""
    messages = [
        Message(
            chat_id=sample_chat_data["chat_id"],
            message_id=msg_id,
            sender="user" if i == 0 else "ai",
            text=text,
            created_at=datetime.now(timezone.utc)
        )
        for i, (msg_id, text) in enumerate(zip(
            sample_chat_data["message_ids"],
            ["Hello, how are you?", "I'm doing great, thanks!"]
        ))
    ]
    
    return Chat(
        user_id=sample_chat_data["user_id"],
        chat_id=sample_chat_data["chat_id"],
        title="Test Chat",
        created_at=datetime.now(timezone.utc),
        updated_at=datetime.now(timezone.utc),
        messages=messages
    )


def make_event(
    method="GET",
    path="/chats",
    body=None,
    user_id=TEST_USER_ID,
    stage="mvp"
):
    """Helper per creare eventi Lambda di test"""
    event = {
        "requestContext": {
            "http": {"method": method},
            "authorizer": {
                "jwt": {
                    "claims": {"sub": user_id}
                }
            }
        },
        "rawPath": f"/{stage}{path}" if stage else path
    }
    
    if body:
        event["body"] = __import__('json').dumps(body)
    
    return event