import json
import pytest
from unittest.mock import MagicMock, ANY

from src.chatbot.chatbot_controller import ChatbotController
from src.chatbot.domain.chat import Chat
from src.chatbot.commands.create_chat_cmd import CreateChatCmd
from src.chatbot.commands.get_chat_cmd import GetChatCmd
from src.chatbot.commands.get_chat_list_cmd import GetChatListCmd
from src.chatbot.commands.delete_chat_cmd import DeleteChatCmd
from src.chatbot.commands.update_chat_cmd import UpdateChatCmd
from src.chatbot.commands.add_chat_message_cmd import AddChatMessageCmd

@pytest.fixture
def mock_crud_service():
    return MagicMock()

@pytest.fixture
def mock_llm_service():
    return MagicMock()

@pytest.fixture
def controller(mock_crud_service, mock_llm_service):
    return ChatbotController(crud_service=mock_crud_service, llm_service=mock_llm_service)

def build_event(method, path, body=None, user_id="user1"):
    return {
        "requestContext": {
            "http": {"method": method},
            "authorizer": {
                "jwt": {
                    "claims": {"sub": user_id}
                }
            }
        },
        "rawPath": path,
        "body": json.dumps(body) if body else None
    }

@pytest.fixture
def sample_chat():
    return Chat(chat_id="chat1", user_id="user1", title="Test Chat", created_at="123", updated_at="123", messages=[])

def test_unauthorized(controller):
    event = build_event("GET", "/chats", user_id=None)
    response = controller.handle(event)
    assert response["statusCode"] == 401
    assert json.loads(response["body"])["message"] == "Unauthorized"

def test_route_not_found(controller):
    event = build_event("GET", "/unknown")
    response = controller.handle(event)
    assert response["statusCode"] == 404

def test_handle_chats_get(controller, mock_crud_service, sample_chat):
    mock_crud_service.get_chat_list.return_value = [sample_chat]
    event = build_event("GET", "/chats")
    
    response = controller.handle(event)
    
    assert response["statusCode"] == 200
    body = json.loads(response["body"])
    assert len(body["chats"]) == 1
    assert body["chats"][0]["chat_id"] == "chat1"
    mock_crud_service.get_chat_list.assert_called_once()

def test_handle_chats_post(controller, mock_crud_service, sample_chat):
    mock_crud_service.create_chat.return_value = sample_chat
    event = build_event("POST", "/chats", {"title": "Test Chat"})
    
    response = controller.handle(event)
    
    assert response["statusCode"] == 201
    body = json.loads(response["body"])
    assert body["chat_id"] == "chat1"
    assert body["title"] == "Test Chat"
    mock_crud_service.create_chat.assert_called_once()

def test_handle_chat_get_success(controller, mock_crud_service, sample_chat):
    mock_crud_service.get_chat.return_value = sample_chat
    event = build_event("GET", "/chats/chat1")
    
    response = controller.handle(event)
    
    assert response["statusCode"] == 200
    body = json.loads(response["body"])
    assert body["chat_id"] == "chat1"
    mock_crud_service.get_chat.assert_called_once()

def test_handle_chat_get_not_found(controller, mock_crud_service):
    mock_crud_service.get_chat.return_value = None
    event = build_event("GET", "/chats/chat1")
    
    response = controller.handle(event)
    
    assert response["statusCode"] == 404
    assert json.loads(response["body"])["message"] == "Chat not found"

def test_handle_chat_delete(controller, mock_crud_service):
    event = build_event("DELETE", "/chats/chat1")
    
    response = controller.handle(event)
    
    assert response["statusCode"] == 204
    mock_crud_service.delete_chat.assert_called_once()

def test_handle_chat_put_success(controller, mock_crud_service, sample_chat):
    mock_crud_service.get_chat.return_value = sample_chat
    updated_chat = Chat(chat_id="chat1", user_id="user1", title="Updated Title", created_at="123", updated_at="123", messages=[])
    mock_crud_service.update_chat.return_value = updated_chat
    
    event = build_event("PUT", "/chats/chat1", {"title": "Updated Title"})
    response = controller.handle(event)
    
    assert response["statusCode"] == 200
    body = json.loads(response["body"])
    assert body["title"] == "Updated Title"

def test_handle_chat_put_missing_title(controller, mock_crud_service, sample_chat):
    mock_crud_service.get_chat.return_value = sample_chat
    event = build_event("PUT", "/chats/chat1", {"title": "   "})
    
    response = controller.handle(event)
    
    assert response["statusCode"] == 400
    assert json.loads(response["body"])["message"] == "Missing arguments"

def test_handle_chat_put_title_too_long(controller, mock_crud_service, sample_chat):
    mock_crud_service.get_chat.return_value = sample_chat
    event = build_event("PUT", "/chats/chat1", {"title": "A" * 41})
    
    response = controller.handle(event)
    
    assert response["statusCode"] == 400
    assert json.loads(response["body"])["message"] == "Title too long"

def test_handle_messages_post_success(controller, mock_crud_service, mock_llm_service, sample_chat):
    mock_crud_service.get_chat.return_value = sample_chat
    mock_llm_service.get_message_response.return_value = "AI response"
    mock_crud_service.add_chat_message.side_effect = ["msg1", "msg2"]
    
    event = build_event("POST", "/chats/chat1/messages", {"message": "Hello AI", "response_mode": "mirror"})
    response = controller.handle(event)
    
    assert response["statusCode"] == 200
    body = json.loads(response["body"])
    assert body["response"] == "AI response"
    assert body["input_message_id"] == "msg1"
    assert body["response_message_id"] == "msg2"
    mock_llm_service.get_message_response.assert_called_once_with(sample_chat, "Hello AI", "mirror")
    assert mock_crud_service.add_chat_message.call_count == 2

def test_handle_messages_post_missing_message(controller, mock_crud_service, sample_chat):
    mock_crud_service.get_chat.return_value = sample_chat
    event = build_event("POST", "/chats/chat1/messages", {"response_mode": "mirror"})
    
    response = controller.handle(event)
    
    assert response["statusCode"] == 400

def test_handle_messages_post_llm_fails(controller, mock_crud_service, mock_llm_service, sample_chat):
    mock_crud_service.get_chat.return_value = sample_chat
    mock_llm_service.get_message_response.return_value = None
    
    event = build_event("POST", "/chats/chat1/messages", {"message": "Hello AI"})
    response = controller.handle(event)
    
    assert response["statusCode"] == 500
