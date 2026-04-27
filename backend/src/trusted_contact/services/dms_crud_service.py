from ports.set_dms_heartbeat_port import SetDmsHeartBeatPort
from ports.get_dms_configuration_settings_port import GetDmsConfigurationSettingsPort
from ports.set_dms_configuration_settings_port import SetDmsConfigurationSettingsPort
from ports.dms_repository_port import DmsRepositoryPort
from domain.dms_configuration_settings import DmsConfigurationSettings


class DmsCRUDService(
    SetDmsHeartBeatPort,
    GetDmsConfigurationSettingsPort,
    SetDmsConfigurationSettingsPort
):

    def __init__(self, repository: DmsRepositoryPort):
        self._repository = repository

    def send_heartbeat(self, user_id: str) -> None:
        """
        Ristabilisce il count down al valore iniziale dei 2 timer.

        :param user_id: chiave per accedere alla entry del db     
        """
        config = self._repository.get_dms_config(user_id)
        if config.is_active:
            self._repository.update_first_counter(user_id, config.first_timer)
            self._repository.update_second_counter(user_id, config.second_timer)


    def get_dms_config(self, user_id: str) -> DmsConfigurationSettings:
        """
        Esegue il fetch dei valori delle impostazioni

        :param user_id: chiave per accedere alla entry del db  

        """
        return self._repository.get_dms_config(user_id)


    def update_dms_configuration_settings(self, config: DmsConfigurationSettings) -> None:
        """
        Update delle dei valori delle impostazioni

        :param config: nuovi valori per le impostazioni
        """
        self._repository.update_dms_config(config)
        self.send_heartbeat(config.user_id)


    def create_dms_configuration_settings(self, user_id: str) -> DmsConfigurationSettings:
        """
        Creazione della entry nel db dei valori delle impostazioni

        :param user_id: chiave creare la entry del db  
        """
        return self._repository.add_dms_config(user_id)