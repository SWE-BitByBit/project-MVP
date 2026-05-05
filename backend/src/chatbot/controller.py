import json

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
MISSING_ARGUMENTS = {"message": "Missing arguments"}
TITLE_TOO_LONG = {"message": "Title too long"}


class ChatbotController:

    def __init__(self, crud_service, llm_service):
        self._crud_service = crud_service
        self._llm_service = llm_service

    # -------------------------
    # HTTP RESPONSE HELPER
    # -------------------------

    def _response(self, status_code, body):
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

    # -------------------------
    # EVENT PARSING HELPERS
    # -------------------------

    def _parse_body(self, event):
        try:
            body = event.get("body")
            if not body:
                return {}
            return json.loads(body)
        except json.JSONDecodeError:
            return {}

    def _get_method(self, event):
        return (
            event.get("requestContext", {})
            .get("http", {})
            .get("method")
        )

    def _get_path(self, event):
        return event.get("rawPath", "")

    def _split_path(self, event):
        stage_path = ['mvp']
        path = self._get_path(event)
        path = [p for p in path.split("/") if p]
        if len(path) > 1 and path[0] in stage_path:
            return path[1:]
        return path

    def _get_user_id(self, event):
        claims = (
            event.get("requestContext", {})
            .get("authorizer", {})
            .get("jwt", {})
            .get("claims", {})
        )
        return claims.get("sub")

    # -------------------------
    # HANDLERS
    # -------------------------

    def _handle_chats_get(self, user_id):
        cmd = GetChatListCmd(user_id=user_id)
        chats = self._crud_service.get_chat_list(cmd)
        return self._response(200, {"chats": [ChatDTO.from_domain(c).to_dict() for c in chats]})

    def _handle_chats_post(self, user_id, body):
        chat_title = body.get("title")
        cmd = (
            CreateChatCmd(user_id=user_id, title=chat_title)
            if chat_title
            else CreateChatCmd(user_id=user_id)
        )
        chat = self._crud_service.create_chat(cmd)
        chat_dto = ChatDTO.from_domain(chat)
        return self._response(201, chat_dto.to_dict())

    def _handle_chat_get(self, user_id, chat_id):
        cmd = GetChatCmd(user_id=user_id, chat_id=chat_id)
        chat = self._crud_service.get_chat(cmd)
        if not chat:
            return self._response(404, CHAT_NOT_FOUND)
        chat_dto = ChatDTO.from_domain(chat)
        return self._response(200, chat_dto.to_dict())

    def _handle_chat_delete(self, user_id, chat_id):
        cmd = DeleteChatCmd(user_id=user_id, chat_id=chat_id)
        self._crud_service.delete_chat(cmd)
        return self._response(204, {})

    def _handle_chat_put(self, user_id, chat_id, body):
        cmd = GetChatCmd(user_id=user_id, chat_id=chat_id)
        chat = self._crud_service.get_chat(cmd)
        if not chat:
            return self._response(404, CHAT_NOT_FOUND)
        
        title = body.get("title")

        if not title or title.strip() == "":
            return self._response(400, MISSING_ARGUMENTS)
        
        if len(title) > 40:
            return self._response(400, TITLE_TOO_LONG)

        update_cmd = UpdateChatCmd(
            user_id=user_id,
            chat_id=chat_id,
            title=body.get("title", chat.title),
        )
        updated_chat = self._crud_service.update_chat(update_cmd)
        chat_dto = ChatDTO.from_domain(updated_chat)
        return self._response(200, chat_dto.to_dict())

    def _handle_messages_post(self, user_id, chat_id, body):
        get_cmd = GetChatCmd(user_id=user_id, chat_id=chat_id)
        chat = self._crud_service.get_chat(get_cmd)
        if not chat:
            return self._response(404, CHAT_NOT_FOUND)

        message = body.get("message")
        response_mode = body.get("response_mode", "default")

        if not message:
            return self._response(400, MISSING_ARGUMENTS)

        llm_response = self._llm_service.get_message_response(chat, message, response_mode)
        if not llm_response:
            return self._response(500, {"message": "Couldn't generate an answer"})

        user_msg_cmd = AddChatMessageCmd(
            user_id=user_id,
            chat_id=chat_id,
            text=message,
            sender="user",
        )
        ai_msg_cmd = AddChatMessageCmd(
            user_id=user_id,
            chat_id=chat_id,
            text=llm_response,
            sender="ai",
        )

        input_message_id = self._crud_service.add_chat_message(user_msg_cmd)
        response_message_id = self._crud_service.add_chat_message(ai_msg_cmd)

        return self._response(
            200,
            {
                "response": llm_response,
                "input_message_id": input_message_id,
                "response_message_id": response_message_id,
            },
        )

    # -------------------------
    # ROUTING
    # -------------------------

    def _route_chats_collection(self, method, user_id, body):
        if method == "GET":
            return self._handle_chats_get(user_id)
        if method == "POST":
            return self._handle_chats_post(user_id, body)
        return self._response(404, ROUTE_NOT_FOUND)

    def _route_chat_resource(self, method, user_id, chat_id, body):
        if method == "GET":
            return self._handle_chat_get(user_id, chat_id)
        if method == "DELETE":
            return self._handle_chat_delete(user_id, chat_id)
        if method == "PUT":
            return self._handle_chat_put(user_id, chat_id, body)
        return self._response(404, ROUTE_NOT_FOUND)

    def _route_chat_messages(self, method, user_id, chat_id, body):
        if method == "POST":
            return self._handle_messages_post(user_id, chat_id, body)
        return self._response(404, ROUTE_NOT_FOUND)

    def handle(self, event):
        method = self._get_method(event)
        user_id = self._get_user_id(event)
        parts = self._split_path(event)
        body = self._parse_body(event)

        if not user_id:
            return self._response(401, UNAUTHORIZED)

        # All chatbot routes start with /chats
        if not parts or parts[0] != "chats":
            return self._response(404, ROUTE_NOT_FOUND)

        # /chats
        if len(parts) == 1:
            return self._route_chats_collection(method, user_id, body)

        # /chats/{chat_id}
        if len(parts) == 2:
            return self._route_chat_resource(method, user_id, parts[1], body)

        # /chats/{chat_id}/messages
        if len(parts) == 3 and parts[2] == "messages":
            return self._route_chat_messages(method, user_id, parts[1], body)

        return self._response(404, ROUTE_NOT_FOUND)
