import pytest
from uuid import uuid4
from datetime import datetime, timezone

TEST_USER_ID = str(uuid4())
TEST_CHAT_ID = str(uuid4())
ANOTHER_USER_ID = str(uuid4())
ANOTHER_CHAT_ID = str(uuid4())


@pytest.fixture(scope="function")
def test_ids():
    """Fixture con tutti gli ID di test"""
    return {
        "user_id": TEST_USER_ID,
        "chat_id": TEST_CHAT_ID,
        "another_user_id": ANOTHER_USER_ID,
        "another_chat_id": ANOTHER_CHAT_ID
    }


@pytest.fixture(scope="function")
def create_test_chat_item(test_ids):
    """Factory per creare item chat di test"""
    def _create_chat_item(
        chat_id=None,
        user_id=None,
        title="Test Chat",
        created_at=None
    ):
        if created_at is None:
            created_at = datetime.now(timezone.utc).isoformat()
        
        return {
            "chat_id": chat_id or test_ids["chat_id"],
            "user_id": user_id or test_ids["user_id"],
            "title": title,
            "created_at": created_at,
            "updated_at": created_at
        }
    
    return _create_chat_item


@pytest.fixture(scope="function")
def create_test_message_items():
    """Factory per creare item messaggi di test"""
    def _create_message_items(
        chat_id,
        count=2,
        start_with_user=True
    ):
        created_at = datetime.now(timezone.utc).isoformat()
        messages = []
        
        for i in range(count):
            sender = "user" if (start_with_user and i % 2 == 0) else "ai"
            messages.append({
                "chat_id": chat_id,
                "message_id": str(uuid4()),
                "text": f"Test message {i+1}",
                "sender": sender,
                "created_at": created_at
            })
        
        return messages
    
    return _create_message_items


@pytest.fixture(scope="function")
def sample_chat_data(mock_dynamodb_table, test_ids, create_test_chat_item, create_test_message_items):
    """Fixture che popola le tabelle con dati di test"""
    chats_table = mock_dynamodb_table["chats"]
    messages_table = mock_dynamodb_table["messages"]
    
    # Inserisci chat
    chat_item = create_test_chat_item()
    chats_table.put_item(Item=chat_item)
    
    # Inserisci messaggi
    messages = create_test_message_items(chat_id=test_ids["chat_id"], count=2)
    for msg in messages:
        messages_table.put_item(Item=msg)
    
    return {
        "chat_id": test_ids["chat_id"],
        "user_id": test_ids["user_id"],
        "chat_item": chat_item,
        "messages": messages
    }