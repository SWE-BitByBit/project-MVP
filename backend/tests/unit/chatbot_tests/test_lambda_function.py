import json
import pytest
from uuid import uuid4
from unittest.mock import patch, Mock, MagicMock
from datetime import datetime, timezone

from src.chatbot.lambda_function import (
    lambda_handler,
    handle_chats_get,
    handle_chats_post,
    handle_chat_get,
    handle_chat_delete,
    handle_chat_put,
    handle_messages_post,
)

from src.chatbot.domain.dtos.chat_dto import ChatDTO
from src.chatbot.services.chatbot_crud_service import ChatbotCRUDService
from src.chatbot.services.chatbot_llm_service import ChatbotLLMService
from src.chatbot.domain.chat import Chat
from src.chatbot.domain.chat_message import Message

from tests.unit.chatbot_tests.conftest import make_event, TEST_USER_ID, TEST_CHAT_ID


def test_handle_chats_get(chat_adapter, sample_chat_data):
    """Test GET /chats"""
    mock_crud_service = Mock(spec=ChatbotCRUDService)
    
    # Crea una lista di chat mockate
    mock_chat = Chat(
        title="Test Chat",
        chat_id=TEST_CHAT_ID,
        user_id=TEST_USER_ID,
        created_at=datetime.now(timezone.utc).isoformat(),
        updated_at=datetime.now(timezone.utc).isoformat(),
        messages=[]
    )
    mock_crud_service.get_chat_list.return_value = [mock_chat]
    
    with patch('src.chatbot.lambda_function.get_crud_service', return_value=mock_crud_service):
        result = handle_chats_get(TEST_USER_ID)
        
        assert result["statusCode"] == 200
        body = json.loads(result["body"])
        assert "chats" in body
        assert len(body["chats"]) >= 1
        mock_crud_service.get_chat_list.assert_called_once()


def test_handle_chats_post(chat_adapter, sample_chat_data):
    """Test POST /chats"""
    mock_crud_service = Mock(spec=ChatbotCRUDService)
    
    # Mock del chat creato
    mock_chat = Chat(
        title="New Chat",
        chat_id=str(uuid4()),
        user_id=TEST_USER_ID,
        created_at=datetime.now(timezone.utc).isoformat(),
        updated_at=datetime.now(timezone.utc).isoformat(),
        messages=[]
    )
    mock_crud_service.create_chat.return_value = mock_chat
    
    with patch('src.chatbot.lambda_function.get_crud_service', return_value=mock_crud_service):
        body = {"title": "New Chat"}
        result = handle_chats_post(TEST_USER_ID, body)
        
        assert result["statusCode"] == 201
        response_body = json.loads(result["body"])
        assert "chat_id" in response_body
        assert response_body["title"] == "New Chat"
        mock_crud_service.create_chat.assert_called_once()


def test_handle_chat_get_found(chat_adapter, sample_chat_data):
    """Test GET /chats/{chat_id} - chat found"""
    mock_crud_service = Mock(spec=ChatbotCRUDService)
    
    mock_messages = [
        Message(
            chat_id=TEST_CHAT_ID,
            message_id=str(uuid4()),
            text="Hello",
            sender="user",
            created_at=datetime.now(timezone.utc)
        ),
        Message(
            chat_id=TEST_CHAT_ID,
            message_id=str(uuid4()),
            text="Hi there!",
            sender="ai",
            created_at=datetime.now(timezone.utc)
        )
    ]
    
    mock_chat = Chat(
        title="Test Chat",
        chat_id=TEST_CHAT_ID,
        user_id=TEST_USER_ID,
        created_at=datetime.now(timezone.utc).isoformat(),
        updated_at=datetime.now(timezone.utc).isoformat(),
        messages=mock_messages
    )
    mock_crud_service.get_chat.return_value = mock_chat
    
    with patch('src.chatbot.lambda_function.get_crud_service', return_value=mock_crud_service):
        result = handle_chat_get(TEST_USER_ID, TEST_CHAT_ID)
        
        assert result["statusCode"] == 200
        dto = ChatDTO.from_domain(mock_chat)
        body = dto.to_dict()
        assert body["chat_id"] == TEST_CHAT_ID
        assert body["user_id"] == TEST_USER_ID
        assert body["title"] == "Test Chat"
        assert "messages" in body
        mock_crud_service.get_chat.assert_called_once()


def test_handle_chat_get_not_found(chat_adapter, sample_chat_data):
    """Test GET /chats/{chat_id} - chat not found"""
    mock_crud_service = Mock(spec=ChatbotCRUDService)
    mock_crud_service.get_chat.return_value = None
    
    with patch('src.chatbot.lambda_function.get_crud_service', return_value=mock_crud_service):
        non_existent_id = str(uuid4())
        result = handle_chat_get(TEST_USER_ID, non_existent_id)
        
        assert result["statusCode"] == 404


def test_handle_chat_delete(chat_adapter, sample_chat_data):
    """Test DELETE /chats/{chat_id}"""
    mock_crud_service = Mock(spec=ChatbotCRUDService)
    
    with patch('src.chatbot.lambda_function.get_crud_service', return_value=mock_crud_service):
        result = handle_chat_delete(TEST_USER_ID, TEST_CHAT_ID)
        
        assert result["statusCode"] == 204
        mock_crud_service.delete_chat.assert_called_once()


def test_handle_chat_put_found(chat_adapter, sample_chat_data):
    """Test PUT /chats/{chat_id} - update title"""
    mock_crud_service = Mock(spec=ChatbotCRUDService)
    
    # Mock del chat esistente
    existing_chat = Chat(
        title="Old Title",
        chat_id=TEST_CHAT_ID,
        user_id=TEST_USER_ID,
        created_at=datetime.now(timezone.utc).isoformat(),
        updated_at=datetime.now(timezone.utc).isoformat(),
        messages=[]
    )
    mock_crud_service.get_chat.return_value = existing_chat
    
    # Mock del chat aggiornato
    updated_chat = Chat(
        title="New Title",
        chat_id=TEST_CHAT_ID,
        user_id=TEST_USER_ID,
        created_at=existing_chat.created_at,
        updated_at=datetime.now(timezone.utc).isoformat(),
        messages=[]
    )
    mock_crud_service.update_chat.return_value = updated_chat
    
    with patch('src.chatbot.lambda_function.get_crud_service', return_value=mock_crud_service):
        body = {"title": "New Title"}
        result = handle_chat_put(TEST_USER_ID, TEST_CHAT_ID, body)
        
        assert result["statusCode"] == 200
        response_body = json.loads(result["body"])
        assert response_body["title"] == "New Title"
        mock_crud_service.get_chat.assert_called_once()
        mock_crud_service.update_chat.assert_called_once()


def test_handle_messages_post(chat_adapter, sample_chat_data):
    """Test POST /chats/{chat_id}/messages"""
    mock_crud_service = Mock(spec=ChatbotCRUDService)
    mock_llm_service = Mock(spec=ChatbotLLMService)
    
    # Mock del chat esistente
    mock_chat = Chat(
        title="Test Chat",
        chat_id=TEST_CHAT_ID,
        user_id=TEST_USER_ID,
        created_at=datetime.now(timezone.utc).isoformat(),
        updated_at=datetime.now(timezone.utc).isoformat(),
        messages=[]
    )
    mock_crud_service.get_chat.return_value = mock_chat
    mock_llm_service.get_message_response.return_value = "This is a mock AI response"
    
    with patch('src.chatbot.lambda_function.get_crud_service', return_value=mock_crud_service):
        with patch('src.chatbot.lambda_function.get_llm_service', return_value=mock_llm_service):
            body = {"message": "Hello AI!"}
            result = handle_messages_post(TEST_USER_ID, TEST_CHAT_ID, body)
            
            assert result["statusCode"] == 200
            response_body = json.loads(result["body"])
            assert "response" in response_body
            assert response_body["response"] == "This is a mock AI response"
            assert response_body["chat_id"] == TEST_CHAT_ID
            
            # Verifica che i messaggi siano stati aggiunti
            assert mock_crud_service.add_chat_message.call_count == 2
            mock_llm_service.get_message_response.assert_called_once()


def test_lambda_handler_integration(chat_adapter, sample_chat_data):
    """Test dell'handler Lambda completo"""
    mock_crud_service = Mock(spec=ChatbotCRUDService)
    
    # Setup del mock per GET /chats
    mock_chat = Chat(
        title="Test Chat",
        chat_id=TEST_CHAT_ID,
        user_id=TEST_USER_ID,
        created_at=datetime.now(timezone.utc).isoformat(),
        updated_at=datetime.now(timezone.utc).isoformat(),
        messages=[]
    )
    mock_crud_service.get_chat_list.return_value = [mock_chat]
    
    event = make_event(method="GET", path="/chats", user_id=TEST_USER_ID)
    
    with patch('src.chatbot.lambda_function.get_crud_service', return_value=mock_crud_service):
        result = lambda_handler(event, None)
        
        assert result["statusCode"] == 200
        body = json.loads(result["body"])
        assert "chats" in body