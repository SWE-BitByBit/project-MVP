from dataclasses import dataclass
from datetime import datetime

@dataclass
class Message:
    message_id: str
    sender: str
    text: str
    created_at: datetime