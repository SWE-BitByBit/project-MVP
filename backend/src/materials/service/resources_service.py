from typing import Final, List

from models.resource import Resource
from ports.get_resources_port import GetResourcesPort
from ports.resources_repository_port import ResourcesRepositoryPort


class ResourcesService(GetResourcesPort):
    """
    Servizio che implementa la business logic per il recupero delle risorse.

    :param repository: Implementazione del repository delle risorse.
    """

    def __init__(self, repository: ResourcesRepositoryPort) -> None:
        self._repository: Final[ResourcesRepositoryPort] = repository

    def get_resources(self) -> List[Resource]:
        """
        Delega al repository il recupero di tutte le risorse.

        :return: Lista di oggetti Resource.
        """
        return self._repository.list_all_resources()