import json

from chatbot_crud_service import ChatbotCRUDService
from chatbot_llm_service import ChatbotLLMService
from dynamo_chat_adapter import DynamoChatAdapter
from bedrock_llm_adapter import BedrockLLMAdapter
from chat_dto import ChatDTO


def response(status_code, body):
    if status_code == 204:
        return {
            "statusCode": status_code,
            "headers": {"Content-Type": "application/json"},
            "body": ""
        }

    return {
        "statusCode": status_code,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps(body)
    }


chat_repo = DynamoChatAdapter()
chat_model = BedrockLLMAdapter()
crud_service = ChatbotCRUDService(chat_repo)
llm_service = ChatbotLLMService(chat_model)


def parse_body(event):
    try:
        body = event.get("body")
        if not body:
            return {}
        return json.loads(body)
    except json.JSONDecodeError:
        return {}


def get_method(event):
    return (
        event.get("requestContext", {})
        .get("http", {})
        .get("method")
    )


def get_path(event):
    return event.get("rawPath", "")


def split_path(event):
    path = get_path(event)
    return [p for p in path.split("/") if p]


def get_user_id(event):
    claims = (
        event.get("requestContext", {})
        .get("authorizer", {})
        .get("jwt", {})
        .get("claims", {})
    )

    return claims.get("sub")


def handle_chats_get(user_id):
    chats = crud_service.list_chats(user_id)
    return response(200, {"chats": [c.__dict__ for c in chats]})


def handle_chats_post(user_id):
    chat = crud_service.create_chat(user_id)
    return response(201, chat.__dict__)


def handle_chat_get(user_id, chat_id):
    chat = crud_service.get_chat(user_id, chat_id)
    if not chat:
        return response(404, {"message": "Chat not found"})

    chat_dto = ChatDTO.from_domain(chat)
    return response(200, chat_dto.to_dict())


def handle_chat_delete(user_id, chat_id):
    ok = crud_service.delete_chat(user_id, chat_id)
    if not ok:
        return response(404, {"message": "Chat not found"})
    return response(204, {})


def handle_chat_put(user_id, chat_id, body):
    chat = crud_service.get_chat(user_id, chat_id)
    if not chat:
        return response(404, {"message": "Chat not found"})

    chat.title = body.get("title", chat.title)
    chat.updated_at = body.get("updated_at", chat.updated_at)
    chat_dto = ChatDTO.from_domain(chat)

    return response(200, chat_dto.to_dict())


def handle_messages_post(user_id, chat_id, body):
    chat = crud_service.get_chat(user_id, chat_id)
    if not chat:
        return response(404, {"message": "Chat not found"})

    message = body.get("message")
    response_mode = body.get("response_mode", "default")

    llm_response = llm_service.get_prompt_response(chat, message, response_mode)
    if not llm_response:
        return response(500, {"message": "Couldn't generate an answer"})
    
    crud_service.add_chat_message(user_id, chat_id, message , "user")
    crud_service.add_chat_message(user_id, chat_id, llm_response , "ai")

    return response(
        200,
        {
            "response": llm_response,
            "chat_id": chat_id,
        },
    )


def route(event):
    method = get_method(event)
    user_id = get_user_id(event)
    parts = split_path(event)
    body = parse_body(event)

    if not user_id:
        return response(401, {"message": "Unauthorized"})

    if len(parts) == 1 and parts[0] == "chats":
        if method == "GET":
            return handle_chats_get(user_id)
        if method == "POST":
            return handle_chats_post(user_id)

    if len(parts) == 2 and parts[0] == "chats":
        chat_id = parts[1]

        if method == "GET":
            return handle_chat_get(user_id, chat_id)

        if method == "DELETE":
            return handle_chat_delete(user_id, chat_id)

        if method == "PUT":
            return handle_chat_put(user_id, chat_id, body)

    if len(parts) == 3 and parts[0] == "chats" and parts[2] == "messages":
        chat_id = parts[1]

        if method == "POST":
            return handle_messages_post(user_id, chat_id, body)

    return response(404, {"message": "Route not found"})


def lambda_handler(event, context):
    return route(event)