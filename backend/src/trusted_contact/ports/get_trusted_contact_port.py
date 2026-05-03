from abc import ABC, abstractmethod
from typing import List, Optional

from commands.get_trusted_contact_command import GetTrustedContactCmd
from domain.trusted_contact import TrustedContact

class GetTrustedContactPort(ABC):

    @abstractmethod
    def get_trusted_contact(self, cmd: GetTrustedContactCmd) -> Optional[TrustedContact]:
        pass

    @abstractmethod
    def get_all_trusted_contact(self, user_id: str) -> Optional[List[TrustedContact]]:
        pass