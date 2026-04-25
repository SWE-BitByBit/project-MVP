from abc import ABC, abstractmethod
from typing import List, Optional
from chatbot.domain.chat import Chat
from chatbot.domain.chat_message import Message

class ChatsRepositoryPort(ABC):
    @abstractmethod
    def create_chat(self, user_id: str, first_message: str) -> Chat:
        pass

    @abstractmethod
    def get_chat(self, user_id: str, chat_id: str) -> Optional[Chat]:
        pass

    @abstractmethod
    def delete_chat(self, user_id: str, chat_id: str) -> bool:
        pass

    @abstractmethod
    def add_chat_message(self, user_id: str, chat_id: str, text: str, sender: str) -> None:
        pass

    @abstractmethod
    def list_chats(self, user_id: str) -> List[Chat]:
        pass