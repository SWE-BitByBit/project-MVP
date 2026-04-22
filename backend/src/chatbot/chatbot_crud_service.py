from typing import List, Optional
from chats_repository_port import ChatsRepositoryPort
from chat import Chat
from chat_message import Message

class ChatbotCRUDService:
    def __init__(self, repo: ChatsRepositoryPort):
        self._repo = repo

    def create_chat(self, user_id: str) -> Chat:
        return self._repo.create_chat(user_id)

    def get_chat(self, user_id: str, chat_id: str) -> Optional[Chat]:
        return self._repo.get_chat(user_id, chat_id)

    def delete_chat(self, user_id: str, chat_id: str) -> bool:
        return self._repo.delete_chat(user_id, chat_id)

    def add_chat_message(self, user_id: str, chat_id: str, text: str, sender: str) -> None:
        self._repo.add_chat_message(user_id, chat_id, text, sender)

    def list_chats(self, user_id: str) -> List[Chat]:
        return self._repo.list_chats(user_id)