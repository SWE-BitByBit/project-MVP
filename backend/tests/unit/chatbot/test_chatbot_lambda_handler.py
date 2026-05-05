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