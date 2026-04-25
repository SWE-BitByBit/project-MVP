import json
import pytest
from uuid import uuid4
from datetime import datetime, timezone

from src.chatbot.commands.create_chat_cmd import CreateChatCmd
from src.chatbot.commands.get_chat_cmd import GetChatCmd
from src.chatbot.commands.get_chat_list_cmd import GetChatListCmd
from src.chatbot.commands.delete_chat_cmd import DeleteChatCmd
from src.chatbot.commands.update_chat_cmd import UpdateChatCmd
from src.chatbot.commands.add_chat_message_cmd import AddChatMessageCmd
from src.chatbot.domain.chat_message import Message
from src.chatbot.lambda_function import lambda_handler
from mock_llm import MockLLM


# ============================================================
# 1. GET CHATS (handle_chats_get)
# ============================================================

def test_handle_chats_get_real(crud_service, sample_chat, tables):
    user_id = sample_chat["user_id"]

    result = crud_service.get_chat_list(
        GetChatListCmd(user_id=user_id)
    )

    assert isinstance(result, list)
    assert len(result) >= 1
    assert all(chat.user_id == user_id for chat in result)


# ============================================================
# 2. POST CHATS (handle_chats_post)
# ============================================================

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


# ============================================================
# 3. GET CHAT BY ID (handle_chat_get_found)
# ============================================================

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


# ============================================================
# 4. GET CHAT NOT FOUND
# ============================================================

def test_handle_chat_get_not_found_real(crud_service, tables):
    cmd = GetChatCmd(
        user_id=str(uuid4()),
        chat_id=str(uuid4())
    )

    chat = crud_service.get_chat(cmd)

    assert chat is None


# ============================================================
# 5. DELETE CHAT
# ============================================================

def test_handle_chat_delete_real(crud_service, sample_chat, tables):
    user_id = sample_chat["user_id"]
    chat_id = sample_chat["chat_id"]

    delete_cmd = DeleteChatCmd(
        user_id=user_id,
        chat_id=chat_id
    )

    crud_service.delete_chat(delete_cmd)

    # verify deletion
    result = crud_service.get_chat(
        GetChatCmd(user_id=user_id, chat_id=chat_id)
    )

    assert result is None


# ============================================================
# 6. UPDATE CHAT TITLE
# ============================================================

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


# ============================================================
# 7. ADD MESSAGE + LLM FLOW (mock LLM not used here)
# ============================================================

def test_handle_messages_post_real(crud_service, sample_chat, tables):
    user_id = sample_chat["user_id"]
    chat_id = sample_chat["chat_id"]

    # user message
    user_msg_cmd = AddChatMessageCmd(
        user_id=user_id,
        chat_id=chat_id,
        text="Hello AI!",
        sender="user"
    )

    crud_service.add_chat_message(user_msg_cmd)

    # simulate AI response (no LLM mock here, pure domain test)
    ai_msg_cmd = AddChatMessageCmd(
        user_id=user_id,
        chat_id=chat_id,
        text="Mock AI response",
        sender="ai"
    )

    crud_service.add_chat_message(ai_msg_cmd)

    # verify messages exist via repository fetch
    chat = crud_service.get_chat(
        GetChatCmd(user_id=user_id, chat_id=chat_id)
    )

    assert chat is not None
    assert len(chat.messages) >= 2

    senders = {m.sender for m in chat.messages}
    assert "user" in senders
    assert "ai" in senders


# ============================================================
# 8. INTEGRATION TEST (lambda handler full path)
# ============================================================

def test_lambda_get_single_chat(crud_service, sample_chat, tables):

    user_id = sample_chat["user_id"]

    event = {
        "requestContext": {
            "http": {"method": "GET"},
            "authorizer": {
                "jwt": {
                    "claims": {"sub": user_id}
                }
            }
        },
        "rawPath": "/mvp/chats"
    }

    result = lambda_handler(event, None)

    assert result["statusCode"] == 200

    body = json.loads(result["body"])
    assert "chats" in body
    assert isinstance(body["chats"], list)




def test_lambda_get_chats(crud_service, sample_chat, tables):

    user_id = sample_chat["user_id"]

    event = {
        "requestContext": {
            "http": {"method": "GET"},
            "authorizer": {"jwt": {"claims": {"sub": user_id}}}
        },
        "rawPath": "/mvp/chats"
    }

    result = lambda_handler(event, None)

    assert result["statusCode"] == 200

    body = json.loads(result["body"])
    assert "chats" in body
    assert len(body["chats"]) >= 1


def test_lambda_create_chat(crud_service, tables):
    user_id = str(uuid4())

    event = {
        "requestContext": {
            "http": {"method": "POST"},
            "authorizer": {"jwt": {"claims": {"sub": user_id}}}
        },
        "rawPath": "/mvp/chats",
        "body": json.dumps({"title": "Lambda Chat"})
    }

    result = lambda_handler(event, None)

    assert result["statusCode"] == 201

    body = json.loads(result["body"])
    assert body["title"] == "Lambda Chat"
    assert body["user_id"] == user_id



def test_lambda_get_chat_by_id(crud_service, sample_chat, tables):

    user_id = sample_chat["user_id"]
    chat_id = sample_chat["chat_id"]

    event = {
        "requestContext": {
            "http": {"method": "GET"},
            "authorizer": {"jwt": {"claims": {"sub": user_id}}}
        },
        "rawPath": f"/mvp/chats/{chat_id}"
    }

    result = lambda_handler(event, None)

    assert result["statusCode"] == 200

    body = json.loads(result["body"])
    assert body["chat_id"] == chat_id
    assert body["user_id"] == user_id


def test_lambda_get_chat_not_found(crud_service, tables):

    user_id = str(uuid4())
    chat_id = str(uuid4())

    event = {
        "requestContext": {
            "http": {"method": "GET"},
            "authorizer": {"jwt": {"claims": {"sub": user_id}}}
        },
        "rawPath": f"/mvp/chats/{chat_id}"
    }

    result = lambda_handler(event, None)

    assert result["statusCode"] == 404


def test_lambda_delete_chat(crud_service, sample_chat, tables):

    user_id = sample_chat["user_id"]
    chat_id = sample_chat["chat_id"]

    event = {
        "requestContext": {
            "http": {"method": "DELETE"},
            "authorizer": {"jwt": {"claims": {"sub": user_id}}}
        },
        "rawPath": f"/mvp/chats/{chat_id}"
    }

    result = lambda_handler(event, None)

    assert result["statusCode"] == 204

    # verify deletion
    get_event = {
        "requestContext": {
            "http": {"method": "GET"},
            "authorizer": {"jwt": {"claims": {"sub": user_id}}}
        },
        "rawPath": f"/mvp/chats/{chat_id}"
    }

    result2 = lambda_handler(get_event, None)
    assert result2["statusCode"] == 404


def test_llm_service_detective(sample_chat, llm_service):
    response = llm_service.get_message_response(
        chat=sample_chat["chat"],
        message="hello ai",
        response_mode="detective"
    )

    assert response == "Mocked response"


def test_llm_service_mirror(sample_chat, llm_service):
    response = llm_service.get_message_response(
        chat=sample_chat["chat"],
        message="hello ai",
        response_mode="mirror"
    )

    assert response == "Mocked response"


def test_llm_service_prompt_length(sample_chat, llm_service):
    response = llm_service.get_message_response(
        chat=sample_chat["chat"],
        message="hello ai",
        response_mode="mirror"
    )

    assert response == "Mocked response"


def test_tokenize(llm_service):
    tokens = llm_service._tokenize("Hello World 123!")

    assert "hello" in tokens
    assert "world" in tokens
    assert "123" in tokens
    assert len(tokens) == 3
    assert "!" not in tokens


def test_build_corpus(llm_service, sample_chat_llm):
    corpus, messages = llm_service._build_corpus(sample_chat_llm)

    assert len(corpus) == len(sample_chat_llm.messages)
    assert len(messages) == len(sample_chat_llm.messages)

    assert isinstance(corpus[0], list)
    assert "machine" in corpus[0]
    assert "learning" in corpus[1]
    assert "pizza" in corpus[2]


def test_retrieve_relevant_messages(llm_service, sample_chat_llm):
    result = llm_service._retrieve_relevant_messages(
        sample_chat_llm,
        query="machine learning"
    )

    assert isinstance(result, list)
    assert len(result) > 0

    joined = " ".join(result).lower()
    assert "learning" in joined or "machine" in joined