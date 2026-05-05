
from uuid import uuid4

from src.chatbot.commands.create_chat_cmd import CreateChatCmd
from src.chatbot.commands.get_chat_cmd import GetChatCmd
from src.chatbot.commands.get_chat_list_cmd import GetChatListCmd
from src.chatbot.commands.delete_chat_cmd import DeleteChatCmd
from src.chatbot.commands.update_chat_cmd import UpdateChatCmd
from src.chatbot.commands.add_chat_message_cmd import AddChatMessageCmd


def test_handle_chats_get_real(crud_service, sample_chat, tables):
    user_id = sample_chat["user_id"]

    result = crud_service.get_chat_list(
        GetChatListCmd(user_id=user_id)
    )

    assert isinstance(result, list)
    assert len(result) >= 1
    assert all(chat.user_id == user_id for chat in result)


def test_handle_chats_post_real(crud_service, tables):
    user_id = str(uuid4())

    cmd = CreateChatCmd(
        user_id=user_id,
        title="New Chat"
    )

    chat = crud_service.create_chat(cmd)

    assert chat is not None
    assert chat.chat_id is not None
    assert chat.title == "New Chat"
    assert chat.user_id == user_id


def test_handle_chat_get_found_real(crud_service, sample_chat, tables):
    user_id = sample_chat["user_id"]
    chat_id = sample_chat["chat_id"]

    cmd = GetChatCmd(
        user_id=user_id,
        chat_id=chat_id
    )

    chat = crud_service.get_chat(cmd)

    assert chat is not None
    assert chat.chat_id == chat_id
    assert chat.user_id == user_id


def test_handle_chat_get_not_found_real(crud_service, tables):
    cmd = GetChatCmd(
        user_id=str(uuid4()),
        chat_id=str(uuid4())
    )

    chat = crud_service.get_chat(cmd)

    assert chat is None


def test_handle_chat_delete_real(crud_service, sample_chat, tables):
    user_id = sample_chat["user_id"]
    chat_id = sample_chat["chat_id"]

    delete_cmd = DeleteChatCmd(
        user_id=user_id,
        chat_id=chat_id
    )

    crud_service.delete_chat(delete_cmd)

    result = crud_service.get_chat(
        GetChatCmd(user_id=user_id, chat_id=chat_id)
    )

    assert result is None


def test_handle_chat_put_real(crud_service, sample_chat, tables):
    user_id = sample_chat["user_id"]
    chat_id = sample_chat["chat_id"]

    update_cmd = UpdateChatCmd(
        user_id=user_id,
        chat_id=chat_id,
        title="Updated Title"
    )

    updated = crud_service.update_chat(update_cmd)

    assert updated is not None
    assert updated.title == "Updated Title"


def test_handle_messages_post_real(crud_service, sample_chat, tables):
    user_id = sample_chat["user_id"]
    chat_id = sample_chat["chat_id"]

    user_msg_cmd = AddChatMessageCmd(
        user_id=user_id,
        chat_id=chat_id,
        text="Hello AI!",
        sender="user"
    )

    crud_service.add_chat_message(user_msg_cmd)

    ai_msg_cmd = AddChatMessageCmd(
        user_id=user_id,
        chat_id=chat_id,
        text="Mock AI response",
        sender="ai"
    )

    crud_service.add_chat_message(ai_msg_cmd)

    chat = crud_service.get_chat(
        GetChatCmd(user_id=user_id, chat_id=chat_id)
    )

    assert chat is not None
    assert len(chat.messages) >= 2

    senders = {m.sender for m in chat.messages}
    assert "user" in senders
    assert "ai" in senders