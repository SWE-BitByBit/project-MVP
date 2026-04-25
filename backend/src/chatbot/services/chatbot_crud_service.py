from typing import List, Optional

from domain.chat import Chat

from ports.chats_repository_port import ChatsRepositoryPort
from ports.get_chat_port import GetChatPort
from ports.delete_chat_port import DeleteChatPort
from ports.create_chat_port import CreateChatPort
from ports.update_chat_port import UpdateChatPort
from ports.chat_message_port import ChatMessagePort

from commands.create_chat_cmd import CreateChatCmd
from commands.get_chat_cmd import GetChatCmd
from commands.get_chat_list_cmd import GetChatListCmd
from commands.delete_chat_cmd import DeleteChatCmd
from commands.update_chat_cmd import UpdateChatCmd
from commands.add_chat_message_cmd import AddChatMessageCmd


class ChatbotCRUDService(
    CreateChatPort,
    GetChatPort,
    UpdateChatPort,
    DeleteChatPort,
    ChatMessagePort,
):
    def __init__(self, repo: ChatsRepositoryPort):
        self._repo = repo

    def create_chat(self, cmd: CreateChatCmd) -> Chat:
        return self._repo.create_chat(
            user_id = cmd.user_id,
            title = cmd.title,
        )

    def get_chat(self, cmd: GetChatCmd) -> Optional[Chat]:
        return self._repo.get_chat(
            user_id = cmd.user_id,
            chat_id = cmd.chat_id,
        )

    def get_chat_list(self, cmd: GetChatListCmd) -> List[Chat]:
        return self._repo.list_chats(
            user_id = cmd.user_id,
        )

    def update_chat(self, cmd: UpdateChatCmd) -> Optional[Chat]:
        return self._repo.update_chat(
            user_id = cmd.user_id,
            chat_id = cmd.chat_id,
            title = cmd.title,
        )

    def delete_chat(self, cmd: DeleteChatCmd) -> None:
        self._repo.delete_chat(
            user_id = cmd.user_id,
            chat_id = cmd.chat_id,
        )

    def add_chat_message(self, cmd: AddChatMessageCmd) -> None:
        self._repo.add_chat_message(
            user_id = cmd.user_id,
            chat_id = cmd.chat_id,
            text = cmd.text,
            sender = cmd.sender,
        )