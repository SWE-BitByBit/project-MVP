from dataclasses import dataclass

@dataclass(frozen=True)
class AddChatMessageCmd:
    user_id: str
    chat_id: str
    text: str
    sender: str

    def __post_init__(self):
        if not self.user_id or not isinstance(self.user_id, str):
            raise ValueError("user_id must be a non-empty string")
        if not self.chat_id or not isinstance(self.chat_id, str):
            raise ValueError("chat_id must be a non-empty string")
        if not self.text or not isinstance(self.text, str):
            raise ValueError("text must be a non-empty string")
        if not self.sender or not isinstance(self.sender, str):
            raise ValueError("sender must be a non-empty string")