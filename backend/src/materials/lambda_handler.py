from typing import Any, Dict, Final

from controller.resources_controller import ResourcesController
from repository.s3_resources_repository import S3ResourcesRepository
from service.resources_service import ResourcesService


def lambda_handler(event: Dict[str, Any], context: Any) -> Dict[str, Any]:
    """
    Punto di ingresso della funzione Lambda AWS.

    :param event: Evento scatenante fornito da AWS.
    :param context: Contesto di esecuzione della Lambda.
    :return: Risposta per API Gateway.
    """
    # Nessuno stato globale: tutti i componenti vengono istanziati ad ogni invocazione
    BUCKET_NAME: Final[str] = "app-protegge-trasforma-materials-mvp"
    FILE_KEY: Final[str] = "materials.json"

    repository = S3ResourcesRepository(BUCKET_NAME, FILE_KEY)
    service = ResourcesService(repository)
    controller = ResourcesController(service)

    return controller.get_resources()