from dataclasses import dataclass
from typing import List
from domain.dtos.chat_message_dto import ChatMessageDTO

@dataclass
class ChatDTO:
    user_id: str
    chat_id: str
    title: str
    created_at: str
    updated_at: str
    messages: List[ChatMessageDTO]

    def to_dict(self) -> dict:
        return {
            "user_id": self.user_id,
            "chat_id": self.chat_id,
            "title": self.title,
            "created_at": self.created_at,
            "updated_at": self.updated_at,
            "messages": [m.to_dict() for m in self.messages]
        }

    @staticmethod
    def from_domain(chat) -> "ChatDTO":
        return ChatDTO(
            user_id=chat.user_id,
            chat_id=chat.chat_id,
            title=chat.title,
            created_at=str(chat.created_at),
            updated_at=str(chat.updated_at),
            messages=[
                ChatMessageDTO.from_domain(m) for m in chat.messages
            ]
        )