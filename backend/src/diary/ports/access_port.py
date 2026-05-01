from abc import ABC, abstractmethod
from commands.login_command import LoginCmd
from commands.logout_command import LogoutCmd


class AccessPort(ABC):
    @abstractmethod
    def login(self, cmd: LoginCmd) -> dict:
        pass

    @abstractmethod
    def logout(self, cmd: LogoutCmd) -> dict:
        pass