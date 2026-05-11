from abc import ABC, abstractmethod
from domain.chat import Chat
from commands.delete_chat_cmd import DeleteChatCmd


class DeleteChatPort(ABC):
    @abstractmethod
    def delete_chat(self, cmd: DeleteChatCmd) -> None:
        pass
