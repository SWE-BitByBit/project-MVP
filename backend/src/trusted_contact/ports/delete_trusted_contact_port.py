from abc import ABC, abstractmethod

from commands.delete_trusted_contact_command import DeleteTrustedContactCmd

class GetTrustedContactPort(ABC):

    @abstractmethod
    def delete_trusted_contact(self, cmd: DeleteTrustedContactCmd) -> bool:
        pass