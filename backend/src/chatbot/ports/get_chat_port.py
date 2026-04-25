from abc import ABC, abstractmethod
from typing import List, Optional
from chatbot.domain.chat import Chat
from chatbot.commands.get_chat_cmd import GetChatCmd
from chatbot.commands.get_chat_list_cmd import GetChatListCmd


class GetChatPort(ABC):
    @abstractmethod
    def get_chat(self, cmd: GetChatCmd) -> Optional[Chat]:
        pass

    @abstractmethod
    def get_chat_list(self, cmd: GetChatListCmd) -> List[Chat]:
        pass