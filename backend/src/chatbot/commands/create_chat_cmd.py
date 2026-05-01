from dataclasses import dataclass

@dataclass(frozen=True)
class CreateChatCmd:
    user_id: str
    title: str = "Nuova chat"

    def __post_init__(self):
        if not self.user_id or not isinstance(self.user_id, str):
            raise ValueError("user_id must be a non-empty string")
