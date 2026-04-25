from dataclasses import dataclass, field
from datetime import datetime
from typing import List
from chatbot.domain.chat_message import Message

@dataclass
class Chat:
    user_id: str
    chat_id: str
    title: str
    created_at: datetime
    updated_at: datetime
    messages: List[Message] = field(default_factory=list)