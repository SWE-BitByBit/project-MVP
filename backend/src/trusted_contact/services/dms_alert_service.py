import os
from typing import List

from domain.email_message import EmailMessage
from domain.trusted_contact import TrustedContact
from domain.dms_configuration_settings import DmsConfigurationSettings
from ports.update_dms_alert_port import UpdateDmsAlertPort
from ports.trusted_contact_repository_port import TrustedContactRepositoryPort
from ports.notification_port import NotificationPort
from ports.dms_repository_port import DmsRepositoryPort

class DmsAlertService(UpdateDmsAlertPort):

    def __init__(
            self,
            contact_repository: TrustedContactRepositoryPort,
            notification_repository: NotificationPort,
            dms_repositopry: DmsRepositoryPort
        ):
            self._contact_repository = contact_repository
            self._notification_repository = notification_repository
            self._dms_repository = dms_repositopry

    def update_dms_timers(self) -> bool:

        configs = self._dms_repository.list_all_configs()

        for config in configs:

            if not config.is_active:
                continue

            first_timer_count_down = self._dms_repository.get_first_timer(config.user_id)
            second_timer_count_down = self._dms_repository.get_second_timer(config.user_id)

            if first_timer_count_down > 0:
                self._dms_repository.update_first_counter(
                     config.user_id, first_timer_count_down - 1 
                )
                if first_timer_count_down - 1 == 0:
                    self._send_user_notification(config)
            
            if second_timer_count_down > 0:
                self._dms_repository.update_second_counter(
                     config.user_id, second_timer_count_down - 1
                )
                if second_timer_count_down - 1 == 0:
                    self._send_contacts_emails(config)

        return True
                 
    
    def _send_user_notification(self, config: DmsConfigurationSettings) -> None:

        message = EmailMessage(
            source_email=os.environ["SOURCE_EMAIL"],
            destination_contact_email="email user",
            subject=config.email_subject,
            body=config.email_body
        )

        self._notification.send_email_message(message)

    def _send_contacts_emails(self, config: DmsConfigurationSettings) -> None:

        contacts: List[TrustedContact] = self._contact_repository.list_trusted_contacts(config.user_id)

        for contact in contacts:

            message = EmailMessage(
                source_email=os.environ["SOURCE_EMAIL"],
                destination_contact_email=contact.contact_email,
                subject="Promemoria di inattività - App Protegge e Trasforma",
                body=self._build_contacts_email_body(config)
            )
            self._notification.send_email_message(message)

    def _build_contacts_email_body(self, config: DmsConfigurationSettings) -> str:
        body = (
            f'?Nome user? non accede alla nostra applicazione -App che Protegge e Trasforma- da {config.second_timer} giorni. Ti avvisiamo in quanto ?nome user? ti ha inserito nei suoi contatti di emergenza. Prova a contattarla per vedere se va tutto bene.'
        )
        return body
          
          

