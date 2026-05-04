from dataclasses import dataclass
from typing import Optional
from domain.diary_type import DiaryType
 
@dataclass(frozen=True)
class SetPasswordCmd:
    user_id: str
    diary_type: DiaryType
    password: str
    previous_password: Optional[str] = None
    
    def __post_init__(self):
        if not self.user_id or not isinstance(self.user_id, str):
            raise ValueError("user_id must be a non-empty string")
        if not isinstance(self.diary_type, DiaryType):
            raise ValueError("diary_type must be a DiaryType enum")
        if not self.password or not isinstance(self.password, str):
            raise ValueError("password must be a non-empty string")