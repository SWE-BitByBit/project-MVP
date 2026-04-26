from abc import ABC, abstractmethod

from domain.email_message import AlertMessage

class NotificationPort(ABC):

    @abstractmethod
    def send_email_message(self, message: AlertMessage) -> str:
        pass