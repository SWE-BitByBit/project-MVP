from abc import ABC, abstractmethod
from commands.login_command import LoginCmd
from commands.logout_command import LogoutCmd
from typing import Optional


class AccessPort(ABC):
    @abstractmethod
    def login(self, cmd: LoginCmd) -> Optional[dict]:
        pass

    @abstractmethod
    def logout(self, cmd: LogoutCmd) -> None:
        pass