from dataclasses import dataclass


@dataclass
class ChatMessageDTO:
    text: str
    sender: str
    created_at: str

    def to_dict(self) -> dict:
        return {
            "text": self.text,
            "sender": self.sender,
            "created_at": self.created_at
        }

    @staticmethod
    def from_domain(message) -> "ChatMessageDTO":
        return ChatMessageDTO(
            text=getattr(message, "text", None),
            sender=getattr(message, "sender", None),
            created_at=getattr(message, "created_at", None)
        )