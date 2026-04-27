from abc import ABC, abstractmethod

from domain.dms_configuration_settings import DmsConfigurationSettings

class SetDmsConfigurationSettingsPort(ABC):

    @abstractmethod
    def update_dms_configuration_settings(self, config: DmsConfigurationSettings) -> None:
        pass

    @abstractmethod
    def create_dms_configuration_settings(self, user_id: str) -> DmsConfigurationSettings:
        pass