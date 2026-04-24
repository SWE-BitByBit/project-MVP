from abc import ABC, abstractmethod
from typing import List

from safe_places.models.marker import Marker


class SafePlacesRepositoryPort(ABC):
    """Interfaccia per l'accesso ai dati dei luoghi sicuri."""

    @abstractmethod
    def list_markers(self) -> List[Marker]:
        """
        Restituisce la lista completa dei marker disponibili.

        :return: Lista di oggetti Marker.
        """