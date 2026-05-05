import json
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
    userMessagesLen = len([
        m for m in sample_chat_llm.messages
        if m.sender != "ai"
    ])

    assert len(corpus) == userMessagesLen
    assert len(messages) == userMessagesLen

    assert isinstance(corpus[0], list)
    assert "machine" in corpus[0]
    assert "learning" not in corpus[1]
    assert "pizza" in corpus[1]


def test_retrieve_relevant_messages(llm_service, sample_chat_llm):
    result = llm_service._retrieve_relevant_messages(
        sample_chat_llm,
        query="machine learning"
    )

    assert isinstance(result, list)
    assert len(result) > 0

    joined = " ".join(result).lower()
    assert "learning" in joined or "machine" in joined

def test_lambda_put_chat(crud_service, sample_chat, tables):
    user_id = sample_chat["user_id"]
    chat_id = sample_chat["chat_id"]

    event = {
        "requestContext": {
            "http": {"method": "PUT"},
            "authorizer": {"jwt": {"claims": {"sub": user_id}}}
        },
        "rawPath": f"/chats/{chat_id}",
        "body": json.dumps({"title": "Updated Lambda Chat"})
    }

    result = lambda_handler(event, None)
    assert result["statusCode"] == 200
    
    body = json.loads(result["body"])
    assert body["title"] == "Updated Lambda Chat"


def test_lambda_put_chat_not_found(crud_service, tables):
    user_id = str(uuid4())
    chat_id = str(uuid4())

    event = {
        "requestContext": {
            "http": {"method": "PUT"},
            "authorizer": {"jwt": {"claims": {"sub": user_id}}}
        },
        "rawPath": f"/chats/{chat_id}",
        "body": json.dumps({"title": "Doesn't matter"})
    }

    result = lambda_handler(event, None)
    assert result["statusCode"] == 404


def test_lambda_post_message(crud_service, sample_chat, tables, monkeypatch):
    from src.chatbot import lambda_function

    class MockLLMSuccess:
        def get_message_response(self, *args, **kwargs):
            return "Mock response"

    controller = lambda_function.get_controller()
    monkeypatch.setattr(controller, "_llm_service", MockLLMSuccess())

    user_id = sample_chat["user_id"]
    chat_id = sample_chat["chat_id"]

    event = {
        "requestContext": {
            "http": {"method": "POST"},
            "authorizer": {"jwt": {"claims": {"sub": user_id}}}
        },
        "rawPath": f"/chats/{chat_id}/messages",
        "body": json.dumps({"message": "Hello from Lambda Integration Test"})
    }

    result = lambda_handler(event, None)
    assert result["statusCode"] == 200
    
    body = json.loads(result["body"])
    assert "response" in body
    assert "input_message_id" in body
    assert "response_message_id" in body


def test_lambda_post_message_not_found(crud_service, tables):
    user_id = str(uuid4())
    chat_id = str(uuid4())

    event = {
        "requestContext": {
            "http": {"method": "POST"},
            "authorizer": {"jwt": {"claims": {"sub": user_id}}}
        },
        "rawPath": f"/chats/{chat_id}/messages",
        "body": json.dumps({"message": "Hello"})
    }

    result = lambda_handler(event, None)
    assert result["statusCode"] == 404


def test_lambda_unauthorized(tables):
    event = {
        "requestContext": {
            "http": {"method": "GET"},
            "authorizer": {"jwt": {"claims": {}}} # No 'sub'
        },
        "rawPath": "/chats"
    }

    result = lambda_handler(event, None)
    assert result["statusCode"] == 401


def test_lambda_invalid_json_body(sample_chat, tables):
    user_id = sample_chat["user_id"]
    chat_id = sample_chat["chat_id"]

    event = {
        "requestContext": {
            "http": {"method": "PUT"},
            "authorizer": {"jwt": {"claims": {"sub": user_id}}}
        },
        "rawPath": f"/chats/{chat_id}",
        "body": "{ invalid json"
    }

    result = lambda_handler(event, None)
    assert result["statusCode"] == 400


def test_lambda_no_body(sample_chat, tables):
    user_id = sample_chat["user_id"]
    chat_id = sample_chat["chat_id"]

    event = {
        "requestContext": {
            "http": {"method": "PUT"},
            "authorizer": {"jwt": {"claims": {"sub": user_id}}}
        },
        "rawPath": f"/chats/{chat_id}"
    }

    result = lambda_handler(event, None)
    assert result["statusCode"] == 400


def test_lambda_invalid_route(sample_chat, tables):
    user_id = sample_chat["user_id"]

    event = {
        "requestContext": {
            "http": {"method": "GET"},
            "authorizer": {"jwt": {"claims": {"sub": user_id}}}
        },
        "rawPath": "/not-chats"
    }

    result = lambda_handler(event, None)
    assert result["statusCode"] == 404


def test_lambda_unknown_method_chats(sample_chat, tables):
    user_id = sample_chat["user_id"]

    event = {
        "requestContext": {
            "http": {"method": "PATCH"},
            "authorizer": {"jwt": {"claims": {"sub": user_id}}}
        },
        "rawPath": "/chats"
    }

    result = lambda_handler(event, None)
    assert result["statusCode"] == 404


def test_lambda_unknown_method_chat_id(sample_chat, tables):
    user_id = sample_chat["user_id"]
    chat_id = sample_chat["chat_id"]

    event = {
        "requestContext": {
            "http": {"method": "PATCH"},
            "authorizer": {"jwt": {"claims": {"sub": user_id}}}
        },
        "rawPath": f"/chats/{chat_id}"
    }

    result = lambda_handler(event, None)
    assert result["statusCode"] == 404


def test_lambda_unknown_method_messages(sample_chat, tables):
    user_id = sample_chat["user_id"]
    chat_id = sample_chat["chat_id"]

    event = {
        "requestContext": {
            "http": {"method": "GET"},
            "authorizer": {"jwt": {"claims": {"sub": user_id}}}
        },
        "rawPath": f"/chats/{chat_id}/messages"
    }

    result = lambda_handler(event, None)
    assert result["statusCode"] == 404


def test_lambda_no_title_post(sample_chat, tables):
    user_id = str(uuid4())

    event = {
        "requestContext": {
            "http": {"method": "POST"},
            "authorizer": {"jwt": {"claims": {"sub": user_id}}}
        },
        "rawPath": "/chats",
        "body": json.dumps({})
    }

    result = lambda_handler(event, None)
    assert result["statusCode"] == 201


def test_lambda_too_many_parts(sample_chat, tables):
    user_id = sample_chat["user_id"]
    chat_id = sample_chat["chat_id"]

    event = {
        "requestContext": {
            "http": {"method": "GET"},
            "authorizer": {"jwt": {"claims": {"sub": user_id}}}
        },
        "rawPath": f"/chats/{chat_id}/messages/something"
    }

    result = lambda_handler(event, None)
    assert result["statusCode"] == 404


def test_lambda_llm_failure(sample_chat, tables, monkeypatch):
    from src.chatbot import lambda_function

    class MockLLMFailure:
        def get_message_response(self, *args, **kwargs):
            return None

    controller = lambda_function.get_controller()
    monkeypatch.setattr(controller, "_llm_service", MockLLMFailure())

    user_id = sample_chat["user_id"]
    chat_id = sample_chat["chat_id"]

    event = {
        "requestContext": {
            "http": {"method": "POST"},
            "authorizer": {"jwt": {"claims": {"sub": user_id}}}
        },
        "rawPath": f"/chats/{chat_id}/messages",
        "body": json.dumps({"message": "Hello"})
    }

    result = lambda_handler(event, None)
    assert result["statusCode"] == 500