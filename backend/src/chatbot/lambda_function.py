import json

from services.chatbot_crud_service import ChatbotCRUDService
from services.chatbot_llm_service import ChatbotLLMService
from adapters.dynamo_chat_adapter import DynamoChatAdapter
from adapters.bedrock_llm_adapter import BedrockLLMAdapter
from domain.dtos.chat_dto import ChatDTO

from commands.create_chat_cmd import CreateChatCmd
from commands.update_chat_cmd import UpdateChatCmd
from commands.get_chat_cmd import GetChatCmd
from commands.get_chat_list_cmd import GetChatListCmd
from commands.delete_chat_cmd import DeleteChatCmd
from commands.add_chat_message_cmd import AddChatMessageCmd

# --- CONSTANTS ---
CHAT_NOT_FOUND = {"message": "Chat not found"}
UNAUTHORIZED = {"message": "Unauthorized"}
ROUTE_NOT_FOUND = {"message": "Route not found"}

_crud_service = None
_llm_service = None

def get_crud_service():
    global _crud_service
    if _crud_service is None:
        chat_repo = DynamoChatAdapter()
        _crud_service = ChatbotCRUDService(chat_repo)
    return _crud_service

def get_llm_service():
    global _llm_service
    if _llm_service is None:
        chat_model = BedrockLLMAdapter()
        _llm_service = ChatbotLLMService(chat_model)
    return _llm_service

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
    stage_path = ['mvp']
    path = get_path(event)
    path = [p for p in path.split("/") if p]
    if (len(path)>1 and path[0] in stage_path):
        return path[1:]
    else:
        return path


def get_user_id(event):
    claims = (
        event.get("requestContext", {})
        .get("authorizer", {})
        .get("jwt", {})
        .get("claims", {})
    )

    return claims.get("sub")


def handle_chats_get(user_id):
    cmd = GetChatListCmd(user_id = user_id)
    chats = get_crud_service().get_chat_list(cmd)
    return response(200, {"chats": [c.__dict__ for c in chats]})


def handle_chats_post(user_id, body):
    chat_title = body.get("title")
    cmd = CreateChatCmd(user_id = user_id, title = chat_title) if chat_title else CreateChatCmd(user_id = user_id)
    chat = get_crud_service().create_chat(cmd)
    chat_dto = ChatDTO.from_domain(chat)
    return response(201, chat_dto.to_dict())


def handle_chat_get(user_id, chat_id):
    cmd = GetChatCmd(user_id = user_id, chat_id = chat_id)
    chat = get_crud_service().get_chat(cmd)
    if not chat:
        return response(404, CHAT_NOT_FOUND)

    chat_dto = ChatDTO.from_domain(chat)
    return response(200, chat_dto.to_dict())


def handle_chat_delete(user_id, chat_id):
    cmd = DeleteChatCmd(user_id = user_id, chat_id = chat_id)
    get_crud_service().delete_chat(cmd)
    return response(204, {})


def handle_chat_put(user_id, chat_id, body):
    cmd = GetChatCmd(user_id=user_id, chat_id=chat_id)
    chat = get_crud_service().get_chat(cmd)
    if not chat:
        return response(404, CHAT_NOT_FOUND)

    update_cmd = UpdateChatCmd(
        user_id = user_id,
        chat_id = chat_id,
        title = body.get("title", chat.title),
    )

    updated_chat = get_crud_service().update_chat(update_cmd)
    chat_dto = ChatDTO.from_domain(updated_chat)

    return response(200, chat_dto.to_dict())


def handle_messages_post(user_id, chat_id, body):
    get_cmd = GetChatCmd(user_id = user_id, chat_id = chat_id)
    chat = get_crud_service().get_chat(get_cmd)
    if not chat:
        return response(404, CHAT_NOT_FOUND)

    message = body.get("message")
    response_mode = body.get("response_mode", "default")

    llm_response = get_llm_service().get_message_response(chat, message, response_mode)
    if not llm_response:
        return response(500, {"message": "Couldn't generate an answer"})

    user_msg_cmd = AddChatMessageCmd(
        user_id = user_id,
        chat_id = chat_id,
        text = message,
        sender = "user",
    )
    ai_msg_cmd = AddChatMessageCmd(
        user_id = user_id,
        chat_id = chat_id,
        text = llm_response,
        sender = "ai",
    )

    input_message_id = get_crud_service().add_chat_message(user_msg_cmd)
    response_message_id = get_crud_service().add_chat_message(ai_msg_cmd)

    return response(
        200,
        {
            "response": llm_response,
            "input_message_id":input_message_id,
            "response_message_id":response_message_id,
        },
    )


def _route_chats_collection(method, user_id, body):
    if method == "GET":
        return handle_chats_get(user_id)
    if method == "POST":
        return handle_chats_post(user_id, body)
    return response(404, ROUTE_NOT_FOUND)


def _route_chat_resource(method, user_id, chat_id, body):
    if method == "GET":
        return handle_chat_get(user_id, chat_id)
    if method == "DELETE":
        return handle_chat_delete(user_id, chat_id)
    if method == "PUT":
        return handle_chat_put(user_id, chat_id, body)
    return response(404, ROUTE_NOT_FOUND)


def _route_chat_messages(method, user_id, chat_id, body):
    if method == "POST":
        return handle_messages_post(user_id, chat_id, body)
    return response(404, ROUTE_NOT_FOUND)


def route(event):
    method = get_method(event)
    user_id = get_user_id(event)
    parts = split_path(event)
    body = parse_body(event)

    if not user_id:
        return response(401, UNAUTHORIZED)

    # All chatbot routes start with /chats
    if not parts or parts[0] != "chats":
        return response(404, ROUTE_NOT_FOUND)

    # /chats
    if len(parts) == 1:
        return _route_chats_collection(method, user_id, body)

    # /chats/{chat_id}
    if len(parts) == 2:
        return _route_chat_resource(method, user_id, parts[1], body)

    # /chats/{chat_id}/messages
    if len(parts) == 3 and parts[2] == "messages":
        return _route_chat_messages(method, user_id, parts[1], body)

    return response(404, ROUTE_NOT_FOUND)


def lambda_handler(event, context):
    return route(event)