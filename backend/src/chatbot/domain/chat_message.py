from dataclasses import dataclass
from datetime import datetime

@dataclass
class Message:
    chat_id: str
    message_id: str
    sender: str
    text: str
    created_at: datetime