from abc import ABC, abstractmethod
from chatbot.domain.chat import Chat
from chatbot.commands.add_chat_message_cmd import AddChatMessageCmd


class ChatMessagePort(ABC):
    @abstractmethod
    def add_chat_message(self, cmd: AddChatMessageCmd) -> None:
        pass