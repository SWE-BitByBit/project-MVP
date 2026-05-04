from abc import ABC, abstractmethod
from commands.set_password_command import SetPasswordCmd

class SetPasswordPort(ABC):
    @abstractmethod
    def set_real_password(self, cmd: SetPasswordCmd) -> None:
        pass

    @abstractmethod
    def set_fake_password(self, cmd: SetPasswordCmd) -> None:
        pass