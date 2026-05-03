from abc import ABC, abstractmethod

from domain.dms_configuration_settings import DmsConfigurationSettings

class GetDmsConfigurationSettingsPort(ABC):

    @abstractmethod
    def get_dms_config(self, user_id: str) -> DmsConfigurationSettings:
        pass