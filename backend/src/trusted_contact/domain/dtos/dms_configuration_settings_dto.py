from dataclasses import dataclass

@dataclass
class DmsConfigurationSettingsDTO:
    user_id: str
    is_active: bool
    first_timer: int
    second_timer: int
    email_subject: str
    email_body: str

    def to_dict(self) -> dict:
        return {
            "user_id": self.user_id,
            "is_active": self.is_active,
            "first_timer": self.first_timer,
            "second_timer": self.second_timer,
            "email_subject": self.email_subject,
            "email_body": self.email_body
        }
    
    @staticmethod
    def from_domain(dms_configuration_settings):
        return DmsConfigurationSettingsDTO(
            user_id=dms_configuration_settings.user_id,
            is_active=dms_configuration_settings.is_active,
            first_timer=dms_configuration_settings.first_timer,
            second_timer=dms_configuration_settings.second_timer,
            email_subject=dms_configuration_settings.email_subject ,
            email_body=dms_configuration_settings.email_body
        )