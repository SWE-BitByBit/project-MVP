from abc import ABC, abstractmethod
from chatbot.domain.chat import Chat
from chatbot.commands.create_chat_cmd import CreateChatCmd


class CreateChatPort(ABC):
    @abstractmethod
    def create_chat(self, cmd: CreateChatCmd) -> Chat:
        pass