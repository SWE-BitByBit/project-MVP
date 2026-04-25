import json
from typing import Any, Dict, Final

from materials.ports.get_resources_port import GetResourcesPort


class ResourcesController:
    """
    Controller che orchestra il recupero delle risorse e costruisce la risposta HTTP.

    :param get_resources_port: Porta per il recupero delle risorse.
    """

    def __init__(self, get_resources_port: GetResourcesPort) -> None:
        self._get_resources_port: Final[GetResourcesPort] = get_resources_port

    def get_resources(self) -> Dict[str, Any]:
        """
        Recupera le risorse e produce la risposta per API Gateway.

        :return: Dizionario compatibile con API Gateway (statusCode, headers, body).
        """
        try:
            resources = self._get_resources_port.get_resources()
            body = [resource.to_dict() for resource in resources]
            return self._response(200, body)
        except Exception as error:
            return self._response(500, {"errorMessage": str(error)})

    def _response(self, status: int, body: Any) -> Dict[str, Any]:
        """
        Costruisce il dizionario di risposta per API Gateway.

        :param status: Codice HTTP di risposta.
        :param body: Contenuto del corpo della risposta.
        :return: Dizionario con statusCode, headers e body.
        """
        return {
            "statusCode": status,
            "headers": {
                "Content-Type": "application/json",
                "Access-Control-Allow-Origin": "*",
            },
            "body": json.dumps(body),
        }