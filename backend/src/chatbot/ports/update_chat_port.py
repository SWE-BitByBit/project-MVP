from abc import ABC, abstractmethod
from typing import List, Optional
from chatbot.domain.chat import Chat
from chatbot.commands.update_chat_cmd import UpdateChatCmd


class UpdateChatPort(ABC):
    @abstractmethod
    def update_chat(self, cmd: UpdateChatCmd) -> Optional[Chat]:
        pass