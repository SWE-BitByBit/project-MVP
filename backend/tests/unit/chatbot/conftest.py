import sys
from pathlib import Path

# Aggiunge src/chatbot al path per gli import interni (es. 'from ports.xxx')
sys.path.insert(0, str(Path(__file__).parent))
import conftest
sys.modules['conftest'] = conftest
sys.path.insert(1, str(Path(__file__).parent.parent.parent.parent / "src" / "chatbot"))
sys.path.insert(2, str(Path(__file__).parent.parent.parent.parent / "src"))

modules_to_clean = ["ports", "controller", "repository", "models", "service", "services", "domain", "adapters", "commands"]
for mod in list(sys.modules.keys()):
    if any(mod == clean_mod or mod.startswith(clean_mod + ".") for clean_mod in modules_to_clean):
        del sys.modules[mod]

import pytest
import boto3
from moto import mock_aws
from uuid import uuid4
from datetime import datetime, timezone

from src.chatbot.adapters.dynamo_chat_adapter import DynamoChatAdapter
from src.chatbot.services.chatbot_crud_service import ChatbotCRUDService
from src.chatbot.services.chatbot_llm_service import ChatbotLLMService
from src.chatbot.commands.create_chat_cmd import CreateChatCmd
from src.chatbot.commands.get_chat_cmd import GetChatCmd
from src.chatbot.commands.get_chat_list_cmd import GetChatListCmd
from src.chatbot.commands.delete_chat_cmd import DeleteChatCmd
from src.chatbot.commands.update_chat_cmd import UpdateChatCmd
from src.chatbot.commands.add_chat_message_cmd import AddChatMessageCmd
from src.chatbot.domain.chat import Chat
from src.chatbot.domain.chat_message import Message
from mock_llm import MockLLM


# -------------------------
# CONSTANTS
# -------------------------

CHATS_TABLE_NAME = "chats_mvp"
MESSAGES_TABLE_NAME = "chats_messages_mvp"


# -------------------------
# AWS MOCK FIXTURE
# -------------------------

@pytest.fixture(scope="function")
def aws_mock():
    with mock_aws():
        yield


# -------------------------
# DYNAMODB FIXTURE
# -------------------------

@pytest.fixture(scope="function")
def dynamodb(aws_mock):
    return boto3.resource("dynamodb", region_name="eu-south-1")


# -------------------------
# TABLES SETUP
# -------------------------

@pytest.fixture(scope="function")
def tables(aws_mock, dynamodb):
    chats_table = dynamodb.create_table(
        TableName=CHATS_TABLE_NAME,
        KeySchema=[
            {"AttributeName": "chat_id", "KeyType": "HASH"}
        ],
        AttributeDefinitions=[
            {"AttributeName": "chat_id", "AttributeType": "S"},
            {"AttributeName": "user_id", "AttributeType": "S"},
        ],
        GlobalSecondaryIndexes=[
            {
                "IndexName": "user_index",
                "KeySchema": [
                    {"AttributeName": "user_id", "KeyType": "HASH"}
                ],
                "Projection": {"ProjectionType": "ALL"},
            }
        ],
        BillingMode="PAY_PER_REQUEST",
    )

    messages_table = dynamodb.create_table(
        TableName=MESSAGES_TABLE_NAME,
        KeySchema=[
            {"AttributeName": "chat_id", "KeyType": "HASH"},
            {"AttributeName": "message_id", "KeyType": "RANGE"},
        ],
        AttributeDefinitions=[
            {"AttributeName": "chat_id", "AttributeType": "S"},
            {"AttributeName": "message_id", "AttributeType": "S"},
        ],
        BillingMode="PAY_PER_REQUEST",
    )

    return chats_table, messages_table


# -------------------------
# REPOSITORY FIXTURE
# -------------------------

@pytest.fixture(scope="function")
def chat_repository(dynamodb, tables):
    """
    Concrete implementation of ChatsRepositoryPort
    """
    return DynamoChatAdapter(dynamodb=dynamodb)


# -------------------------
# CRUD SERVICE FIXTURE
# -------------------------

@pytest.fixture(scope="function")
def crud_service(chat_repository):
    """
    ChatbotCRUDService (command-based)
    """
    return ChatbotCRUDService(repo=chat_repository)


# -------------------------
# SAMPLE DATA FIXTURE
# -------------------------

@pytest.fixture(scope="function")
def sample_chat(crud_service):
    """
    Creates a real chat using the command layer (NO mocking)
    """
    user_id = str(uuid4())

    cmd = CreateChatCmd(
        user_id=user_id,
        title="Test Chat",
    )

    chat = crud_service.create_chat(cmd)

    return {
        "user_id": user_id,
        "chat_id": chat.chat_id,
        "chat": chat,
    }


# -------------------------
# LAMBDA EVENT BUILDER
# -------------------------

def make_event(method="GET", path="/chats", body=None, user_id=None, stage="mvp"):
    event = {
        "requestContext": {
            "http": {"method": method},
            "authorizer": {
                "jwt": {
                    "claims": {"sub": user_id}
                }
            }
        },
        "rawPath": f"/{stage}{path}",
    }

    if body is not None:
        import json
        event["body"] = json.dumps(body)

    return event

# -------------------------
# LLM SERVICE FIXTURE
# -------------------------

@pytest.fixture(scope="function")
def llm_service():
    model = MockLLM()

    service = ChatbotLLMService(
        model=model,
        top_k=5
    )

    return service

# -------------------------
# LLM CHAT FIXTURE
# -------------------------

@pytest.fixture
def sample_chat_llm():
    return Chat(
        chat_id=str(uuid4()),
        user_id=str(uuid4()),
        title="Test Chat",
        created_at=datetime.now(timezone.utc),
        updated_at=datetime.now(timezone.utc),
        messages=[
            Message(
                chat_id="1",
                message_id="m1",
                text="I like machine learning",
                sender="user",
                created_at=datetime.now(timezone.utc),
            ),
            Message(
                chat_id="1",
                message_id="m2",
                text="machine learning is a subset of ML",
                sender="ai",
                created_at=datetime.now(timezone.utc),
            ),
            Message(
                chat_id="1",
                message_id="m3",
                text="I like pizza",
                sender="user",
                created_at=datetime.now(timezone.utc),
            ),
        ],
    )