from typing import Final, List

from models.marker import Marker
from ports.get_marker_port import GetMarkerPort
from ports.safe_places_repository_port import SafePlacesRepositoryPort


class SafePlacesService(GetMarkerPort):
    """
    Servizio che implementa la business logic per il recupero dei luoghi sicuri.

    :param repository: Implementazione del repository dei luoghi sicuri.
    """

    def __init__(self, repository: SafePlacesRepositoryPort) -> None:
        self._repository: Final[SafePlacesRepositoryPort] = repository

    def get_all_markers(self) -> List[Marker]:
        """
        Delega al repository il recupero di tutti i marker.

        :return: Lista di oggetti Marker.
        """
        return self._repository.list_markers()