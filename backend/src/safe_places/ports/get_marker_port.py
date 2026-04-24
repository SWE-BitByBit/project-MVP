from abc import ABC, abstractmethod
from typing import List

from safe_places.models.marker import Marker


class GetMarkerPort(ABC):
    """Interfaccia che espone il caso d'uso di recupero dei marker."""

    @abstractmethod
    def get_all_markers(self) -> List[Marker]:
        """
        Recupera tutti i marker disponibili.

        :return: Lista di oggetti Marker.
        """