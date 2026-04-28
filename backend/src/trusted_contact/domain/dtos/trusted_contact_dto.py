from dataclasses import dataclass

@dataclass
class TrustedContactDTO:
    user_id: str
    contact_id: str
    contact_name: str
    contact_email: str
    contact_phone_number: str

    def to_dict(self) -> dict:
        return {
            "user_id": self.user_id,
            "contact_id": self.contact_id,
            "contact_name": self.contact_name,
            "contact_email": self.contact_email,
            "contact_phone_number": self.contact_phone_number
        }
    
    @staticmethod
    def from_domain(trusted_contact):
        return TrustedContactDTO(
            user_id=trusted_contact.user_id,
            contact_id=trusted_contact.contact_id,
            contact_name=trusted_contact.contact_name,
            contact_email=trusted_contact.contact_email,
            contact_phone_number=trusted_contact.contact_phone_number
        )