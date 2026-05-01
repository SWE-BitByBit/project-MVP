from abc import ABC, abstractmethod
from typing import List, Optional

from domain.trusted_contact import TrustedContact

class TrustedContactRepositoryPort(ABC):
    @abstractmethod
    def add(self, contact: TrustedContact) -> Optional[TrustedContact]:
        pass
    
    @abstractmethod
    def get(self, user_id: str, contact_id: str) -> Optional[TrustedContact]:
        pass

    @abstractmethod
    def delete(self, user_id: str, contact_id: str) -> None:
        pass

    @abstractmethod
    def update(self, contact: TrustedContact) -> Optional[TrustedContact]:
        pass

    @abstractmethod
    def list(self, user_id: str) -> Optional[List[TrustedContact]]:
        pass