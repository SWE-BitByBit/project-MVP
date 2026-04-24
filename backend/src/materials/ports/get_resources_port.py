from abc import ABC, abstractmethod
from typing import List

from materials.models.resource import Resource


class GetResourcesPort(ABC):
    """Interfaccia che espone il caso d'uso di recupero delle risorse."""

    @abstractmethod
    def get_resources(self) -> List[Resource]:
        """
        Recupera tutte le risorse disponibili.

        :return: Lista di oggetti Resource.
        """