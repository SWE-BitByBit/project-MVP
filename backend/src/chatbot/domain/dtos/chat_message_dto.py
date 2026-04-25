from dataclasses import dataclass


@dataclass
class ChatMessageDTO:
    chat_id: str
    message_id: str
    text: str
    sender: str
    created_at: str

    def to_dict(self) -> dict:
        return {
            "chat_id": self.chat_id,
            "message_id": self.message_id,
            "text": self.text,
            "sender": self.sender,
            "created_at": self.created_at
        }

    @staticmethod
    def from_domain(message) -> "ChatMessageDTO":
        return ChatMessageDTO(
            chat_id=getattr(message, "chat_id", None),
            message_id=getattr(message, "message_id", None),
            text=getattr(message, "text", None),
            sender=getattr(message, "sender", None),
            created_at=str(getattr(message, "created_at", None))
        )