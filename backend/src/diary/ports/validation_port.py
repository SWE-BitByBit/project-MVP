from abc import ABC, abstractmethod
from commands.validate_password_command import ValidatePasswordCmd
from commands.validate_token_command import ValidateTokenCmd
from domain.diary_type import DiaryType
from typing import Optional


class ValidationPort(ABC):
    @abstractmethod
    def validate_password(self, cmd: ValidatePasswordCmd) -> Optional[DiaryType]:
        pass

    @abstractmethod
    def validate_token(self, cmd: ValidateTokenCmd) -> bool:
        pass