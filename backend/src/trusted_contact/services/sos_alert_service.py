import os

from ports.send_alert_port import SendAlertPort
from ports.trusted_contact_repository_port import TrustedContactRepositoryPort
from ports.notification_port import NotificationPort
from commands.alert_command import AlertCmd
from domain.email_message import EmailMessage

class SOSAlertService(SendAlertPort):

    def __init__(self, contact_repository: TrustedContactRepositoryPort, notification_repository: NotificationPort):
        self._contact_repository = contact_repository
        self._notification_repository = notification_repository

    def send_alert_emails(self, cmd: AlertCmd) -> bool:
        contacts = self._contact_repository.get_all_trusted_contact(cmd.user_id)

        if not contacts:
            return False
        
        for contact in contacts:
            message = self._build_alert_message(cmd, contact.contact_email)
            self._notification_repository.send_email_message(message)
        return True

    def _build_alert_message(self, cmd: AlertCmd, contact_email: str) -> EmailMessage:
        return EmailMessage(
            source_email=os.environ["SOURCE_EMAIL"],
            destination_contact_email=contact_email,
            subject=f'Messaggio di emergenza da {cmd.user_name}',
            body=self._build_alert_body(cmd)
        )

    def _build_alert_body(self, cmd: AlertCmd) -> str:
        maps_url = (
            f"https://www.google.com/maps?q={cmd.latitude},{cmd.longitude}"
            if cmd.latitude is not None and cmd.longitude is not None
            else None
        )
        location_html = (
            f'<p><a href="{maps_url}">Apri posizione in Google Maps</a></p>'
            if maps_url
            else '<p>Posizione non disponibile.</p>'
        )
        message_body = (
            f"<p> Ti è arrivato questo messaggio perchè {cmd.user_name} ha inviato un seganle di emergenza tramite app. Chiamala/o il prima possibile per sapere se è tutto apposto.</p>"
        )
        return f"""
            <h2>Ciao questo è un messaggio di aiuto dall'applicazione App che protegge e trasforma,</h2>
            <p>{message_body}</p>
            {location_html}
        """

