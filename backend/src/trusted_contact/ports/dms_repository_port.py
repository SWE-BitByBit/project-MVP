from abc import ABC, abstractmethod

from domain.dms_configuration_settings import DmsConfigurationSettings

class DmsRepositoryPort(ABC):

    @abstractmethod
    def update_dms_config(self, config: DmsConfigurationSettings) -> None:
        pass

    @abstractmethod
    def get_dms_config(self, user_id: str) -> DmsConfigurationSettings:
        pass

    @abstractmethod
    def add_dms_config(self, user_id: str, user_email: str, user_name: str) -> DmsConfigurationSettings:
        pass

    @abstractmethod
    def get_first_timer(self, user_id: str) -> int:
        pass

    @abstractmethod
    def get_second_timer(self, user_id: str) -> int:
        pass

    @abstractmethod
    def update_first_counter(self, user_id: str, remaining_days: int) -> None:
        pass

    @abstractmethod
    def update_second_counter(self, user_id: str, remaining_days: int) -> None:
        pass

    @abstractmethod
    def list_all_configs(self) -> list[DmsConfigurationSettings]:
        pass

    @abstractmethod
    def get_user_email(self, user_id: str) -> str:
        pass

    @abstractmethod
    def get_user_name(self, user_id: str) -> str:
        pass