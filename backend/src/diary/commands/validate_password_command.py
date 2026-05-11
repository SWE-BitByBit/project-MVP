from dataclasses import dataclass
 
@dataclass(frozen=True)
class ValidatePasswordCmd:
    user_id: str
    password: str
    
    def __post_init__(self):
        if not self.user_id or not isinstance(self.user_id, str):
            raise ValueError("user_id must be a non-empty string")
        if not self.password or not isinstance(self.password, str):
            raise ValueError("password must be a non-empty string")