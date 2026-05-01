from abc import ABC, abstractmethod
from typing import Optional, Dict
from domain.diary_type import DiaryType


class DiaryAuthRepositoryPort(ABC):
    
    @abstractmethod
    def hash_password(self, password: str, user_id: str) -> str:
        pass
    
    @abstractmethod
    def start_session(self, user_id: str) -> str:
        pass

    @abstractmethod
    def end_session(self, user_id: str) -> None:
        pass

    @abstractmethod
    def validate_password(self, password: str, user_id: str) -> Optional[DiaryType]:
        pass

    @abstractmethod
    def validate_token(self, token: str, user_id: str) -> bool:
        pass
    
    @abstractmethod
    def set_password(
        self, 
        password: str, 
        user_id: str, 
        diary_type: DiaryType
    ) -> bool:
        pass
    
    @abstractmethod
    def get_user_passwords(self, user_id: str) -> Optional[Dict[str, Optional[str]]]:
        pass