from typing import List, Optional
from uuid import uuid4

from commands.add_trusted_contact_command import AddTrustedContactCmd
from commands.get_trusted_contact_command import GetTrustedContactCmd
from domain.trusted_contact import TrustedContact

from ports.get_trusted_contact_port import GetTrustedContactPort
from ports.set_trusted_contact_port import SetTrustedContactPort
from ports.delete_trusted_contact_port import DeleteTrustedContactCmd
from ports.trusted_contact_repository_port import TrustedContactRepositoryPort

class TrustedContactCRUDService(
    GetTrustedContactPort,
    SetTrustedContactPort,
    DeleteTrustedContactCmd
):
    def __init__(self, repository: TrustedContactRepositoryPort):
        self._repository = repository

    def update_trusted_contact(self, contact: TrustedContact) -> Optional[TrustedContact]:
        return self._repository.update(contact)
    
    def add_trusted_contact(self, cmd: AddTrustedContactCmd) -> Optional[TrustedContact]:
        contact = TrustedContact(
            user_id=cmd.user_id,
            contact_id=str(uuid4()),
            contact_name=cmd.contact_name,
            contact_email=cmd.contact_email,
            contact_phone_number=cmd.contact_phone_number
        )
        return self._repository.add(contact)

    def get_trusted_contact(self, cmd: GetTrustedContactCmd) -> Optional[TrustedContact]:
        return self._repository.get_trusted_contact(cmd.user_id, cmd.contact_id)
    
    def get_all_trusted_contact(self, user_id: str) -> Optional[List[TrustedContact]]:
        return self._repository.list(user_id)
    
    def delete_trusted_contact(self, cmd: DeleteTrustedContactCmd) -> bool:
        try:
            self._repository.delete(cmd.user_id, cmd.contact_id)
            return True
        except KeyError:
            return False
