from abc import ABC, abstractmethod

class UpdateDmsAlertPort(ABC):

    @abstractmethod
    def update_dms_timers(self) -> bool:
        pass