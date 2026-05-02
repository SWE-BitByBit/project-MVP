from abc import ABC, abstractmethod

from commands.alert_command import AlertCmd

class SendAlertPort(ABC):

    @abstractmethod
    def send_alert_emails(self, cmd: AlertCmd) -> bool:
        pass