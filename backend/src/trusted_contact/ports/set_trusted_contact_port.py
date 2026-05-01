from abc import ABC, abstractmethod
from typing import Optional

from domain.trusted_contact import TrustedContact
from commands.add_trusted_contact_command import AddTrustedContactCmd

class SetTrustedContactPort(ABC):

    @abstractmethod
    def update_trusted_contact(self, contact: TrustedContact) -> Optional[TrustedContact]:
        pass

    @abstractmethod
    def add_trusted_contact(self, cmd: AddTrustedContactCmd) -> Optional[TrustedContact]:
        pass

