from abc import ABC, abstractmethod
from domain.chat import Chat
from commands.create_chat_cmd import CreateChatCmd


class CreateChatPort(ABC):
    @abstractmethod
    def create_chat(self, cmd: CreateChatCmd) -> Chat:
        pass