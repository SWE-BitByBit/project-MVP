from abc import ABC, abstractmethod

class SetDmsHeartBeatPort(ABC):

    @abstractmethod
    def send_heartbeat(self, user_id: str) -> None:
        pass