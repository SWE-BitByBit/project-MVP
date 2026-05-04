from dataclasses import dataclass
 
@dataclass(frozen=True)
class ValidateTokenCmd:
    user_id: str
    token: str
    
    def __post_init__(self):
        if not self.user_id or not isinstance(self.user_id, str):
            raise ValueError("user_id must be a non-empty string")
        if not self.token or not isinstance(self.token, str):
            raise ValueError("token must be a non-empty string")