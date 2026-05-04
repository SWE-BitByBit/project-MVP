from abc import ABC, abstractmethod


class CheckPasswordStatusPort(ABC):
    @abstractmethod
    def check_password_status(self, user_id: str) -> bool:
        pass