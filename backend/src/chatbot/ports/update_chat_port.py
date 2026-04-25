from abc import ABC, abstractmethod
from domain.chat import Chat
from typing import List, Optional
from commands.update_chat_cmd import UpdateChatCmd


class UpdateChatPort(ABC):
    @abstractmethod
    def update_chat(self, cmd: UpdateChatCmd) -> Optional[Chat]:
        pass