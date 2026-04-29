from abc import ABC, abstractmethod
from typing import List

from models.resource import Resource


class ResourcesRepositoryPort(ABC):
    """Interfaccia per l'accesso ai dati delle risorse."""

    @abstractmethod
    def list_all_resources(self) -> List[Resource]:
        """
        Restituisce la lista completa delle risorse disponibili.

        :return: Lista di oggetti Resource.
        """