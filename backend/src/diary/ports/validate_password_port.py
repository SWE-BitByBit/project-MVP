from abc import ABC, abstractmethod
from commands.validate_password_command import ValidatePasswordCmd


class ValidatePasswordPort(ABC):
    @abstractmethod
    def validate_password(self, cmd: ValidatePasswordCmd) -> str:
        pass