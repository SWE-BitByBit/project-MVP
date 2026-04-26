from dataclasses import dataclass
from abc import ABC

@dataclass
class AlertTemplate:
    subject: str
    body: str

@dataclass
class UserLocation:
    latitude: float | None = None
    longitude: float | None = None

@dataclass
class EmailMessage(ABC):
    source_email: str
    contact_name: str
    destination_contact_email: str

@dataclass
class AlertMessage(EmailMessage):
    user_location: UserLocation

@dataclass
class DmsMessage(EmailMessage):
    email_template: AlertTemplate