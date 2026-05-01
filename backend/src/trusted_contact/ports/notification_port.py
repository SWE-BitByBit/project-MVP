from abc import ABC, abstractmethod

from domain.email_message import EmailMessage

class NotificationPort(ABC):

    @abstractmethod
    def send_email_message(self, message: EmailMessage) -> str:
        pass