from typing import Any, Dict, Final

from safe_places.controller.safe_places_controller import SafePlacesController
from safe_places.repository.s3_safe_places_repository import S3SafePlacesRepository
from safe_places.service.safe_places_service import SafePlacesService


def lambda_handler(event: Dict[str, Any], context: Any) -> Dict[str, Any]:
    """
    Punto di ingresso della funzione Lambda AWS.

    :param event: Evento scatenante fornito da AWS.
    :param context: Contesto di esecuzione della Lambda.
    :return: Risposta per API Gateway.
    """
    try:
        # Gestione CORS preflight e filtro per le richieste diverse da GET
        method = event.get("httpMethod")
        if not method:
            method = event.get("requestContext", {}).get("http", {}).get("method")

        if method == "OPTIONS":
            return {
                "statusCode": 200,
                "headers": {
                    "Access-Control-Allow-Origin": "*",
                    "Access-Control-Allow-Methods": "GET, OPTIONS",
                    "Access-Control-Allow-Headers": "Content-Type",
                },
                "body": ""
            }

        if method != "GET":
            return {
                "statusCode": 405,
                "headers": {
                    "Access-Control-Allow-Origin": "*",
                },
                "body": "Method Not Allowed"
            }

        # Nessuno stato globale: tutti i componenti vengono istanziati ad ogni invocazione
        BUCKET_NAME: Final[str] = "app-protegge-trasforma-luoghi-sicuri-mvp"
        FILE_KEY: Final[str] = "luoghi-sicuri.json"

        repository = S3SafePlacesRepository(BUCKET_NAME, FILE_KEY)
        service = SafePlacesService(repository)
        controller = SafePlacesController(service)

        return controller.marker_get(event)
    except Exception as e:
        import traceback
        return {
            "statusCode": 500,
            "headers": {
                "Access-Control-Allow-Origin": "*",
            },
            "body": f"Unhandled Exception: {traceback.format_exc()}"
        }