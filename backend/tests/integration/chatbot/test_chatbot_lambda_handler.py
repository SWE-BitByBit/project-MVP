"""
Test di integrazione: Lambda Handler Chatbot + DynamoDB (emulato con moto).

Verifica che il lambda_handler risponda correttamente agli eventi HTTP
attraverso l'intera catena Handler -> Controller -> Service -> Adapter -> DynamoDB.
"""

import json
from uuid import uuid4
from src.chatbot.lambda_function import lambda_handler


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
        "rawPath": "/chats"
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
        "rawPath": "/chats"
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
        "rawPath": "/chats",
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
        "rawPath": f"/chats/{chat_id}"
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
        "rawPath": f"/chats/{chat_id}"
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
        "rawPath": f"/chats/{chat_id}"
    }

    result = lambda_handler(event, None)

    assert result["statusCode"] == 204

    get_event = {
        "requestContext": {
            "http": {"method": "GET"},
            "authorizer": {"jwt": {"claims": {"sub": user_id}}}
        },
        "rawPath": f"/chats/{chat_id}"
    }

    result2 = lambda_handler(get_event, None)
    assert result2["statusCode"] == 404


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
