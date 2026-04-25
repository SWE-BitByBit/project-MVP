import pytest
from unittest.mock import Mock, patch, MagicMock
from src.chatbot.adapters.bedrock_llm_adapter import BedrockLLMAdapter


@pytest.fixture(scope="function")
def mock_llm_adapter():
    """Fixture per mock del BedrockLLMAdapter"""
    mock = Mock(spec=BedrockLLMAdapter)
    mock.invoke_model = Mock(return_value="Mocked LLM response")
    mock.generate_response = Mock(return_value="Mocked response from AI")
    return mock


@pytest.fixture(scope="function")
def mock_llm_service():
    """Fixture per mock del ChatbotLLMService"""
    with patch('chatbot_llm_service.ChatbotLLMService') as MockService:
        mock_instance = Mock()
        mock_instance.get_message_response = Mock(return_value="Mocked AI response")
        mock_instance._tokenize = Mock(return_value=["test", "tokens"])
        mock_instance._build_corpus = Mock(return_value=(["corpus"], ["raw"]))
        mock_instance._retrieve_relevant_messages = Mock(return_value=["relevant message"])
        MockService.return_value = mock_instance
        yield mock_instance


@pytest.fixture(scope="function")
def mock_crud_service():
    """Fixture per mock del ChatbotCRUDService"""
    with patch('chatbot_crud_service.ChatbotCRUDService') as MockService:
        mock_instance = Mock()
        mock_instance.create_chat = Mock(return_value={
            "chat_id": "test-id",
            "user_id": "test-user",
            "title": "Test Chat"
        })
        mock_instance.get_chat = Mock(return_value={
            "chat_id": "test-id",
            "user_id": "test-user",
            "title": "Test Chat",
            "messages": []
        })
        mock_instance.list_chats = Mock(return_value=[
            {"chat_id": "id1", "title": "Chat 1"},
            {"chat_id": "id2", "title": "Chat 2"}
        ])
        mock_instance.update_chat = Mock(return_value={
            "chat_id": "test-id",
            "title": "Updated Title"
        })
        mock_instance.delete_chat = Mock(return_value=True)
        mock_instance.add_message = Mock(return_value=True)
        MockService.return_value = mock_instance
        yield mock_instance


@pytest.fixture(scope="function")
def mock_boto3_bedrock():
    """Fixture per mock delle chiamate boto3 a Bedrock"""
    with patch('boto3.client') as mock_client:
        mock_bedrock = Mock()
        mock_client.return_value = mock_bedrock
        mock_bedrock.invoke_model = Mock(return_value={
            'body': Mock(read=lambda: b'{"response": "Mocked bedrock response"}')
        })
        yield mock_bedrock