import pytest
from unittest.mock import MagicMock

from src.chatbot.services.chatbot_crud_service import ChatbotCRUDService
from src.chatbot.domain.chat import Chat
from src.chatbot.commands.create_chat_cmd import CreateChatCmd
from src.chatbot.commands.get_chat_cmd import GetChatCmd
from src.chatbot.commands.get_chat_list_cmd import GetChatListCmd
from src.chatbot.commands.delete_chat_cmd import DeleteChatCmd
from src.chatbot.commands.update_chat_cmd import UpdateChatCmd
from src.chatbot.commands.add_chat_message_cmd import AddChatMessageCmd

@pytest.fixture
def mock_repository():
    return MagicMock()

@pytest.fixture
def service(mock_repository):
    return ChatbotCRUDService(repo=mock_repository)

@pytest.fixture
def sample_chat():
    return Chat(chat_id="chat1", user_id="user1", title="Test Chat", created_at="123", updated_at="123", messages=[])

def test_create_chat(service, mock_repository, sample_chat):
    mock_repository.create_chat.return_value = sample_chat
    cmd = CreateChatCmd(user_id="user1", title="Test Chat")
    
    result = service.create_chat(cmd)
    
    assert result == sample_chat
    mock_repository.create_chat.assert_called_once_with(user_id="user1", title="Test Chat")

def test_get_chat(service, mock_repository, sample_chat):
    mock_repository.get_chat.return_value = sample_chat
    cmd = GetChatCmd(user_id="user1", chat_id="chat1")
    
    result = service.get_chat(cmd)
    
    assert result == sample_chat
    mock_repository.get_chat.assert_called_once_with(user_id="user1", chat_id="chat1")

def test_get_chat_list(service, mock_repository, sample_chat):
    mock_repository.list_chats.return_value = [sample_chat]
    cmd = GetChatListCmd(user_id="user1")
    
    result = service.get_chat_list(cmd)
    
    assert result == [sample_chat]
    mock_repository.list_chats.assert_called_once_with(user_id="user1")

def test_update_chat(service, mock_repository, sample_chat):
    mock_repository.update_chat.return_value = sample_chat
    cmd = UpdateChatCmd(user_id="user1", chat_id="chat1", title="New Title")
    
    result = service.update_chat(cmd)
    
    assert result == sample_chat
    mock_repository.update_chat.assert_called_once_with(user_id="user1", chat_id="chat1", title="New Title")

def test_delete_chat(service, mock_repository):
    cmd = DeleteChatCmd(user_id="user1", chat_id="chat1")
    
    service.delete_chat(cmd)
    
    mock_repository.delete_chat.assert_called_once_with(user_id="user1", chat_id="chat1")

def test_add_chat_message(service, mock_repository):
    mock_repository.add_chat_message.return_value = "msg-uuid"
    cmd = AddChatMessageCmd(user_id="user1", chat_id="chat1", text="Hello", sender="user")
    
    result = service.add_chat_message(cmd)
    
    assert result == "msg-uuid"
    mock_repository.add_chat_message.assert_called_once_with(
        user_id="user1", chat_id="chat1", text="Hello", sender="user"
    )