import json
from typing import Any, Dict, Final

from safe_places.ports.get_marker_port import GetMarkerPort


class SafePlacesController:
    """
    Controller che orchestra il recupero dei marker e costruisce la risposta HTTP.

    :param get_marker: Porta per il recupero dei marker.
    """

    def __init__(self, get_marker: GetMarkerPort) -> None:
        self._get_marker: Final[GetMarkerPort] = get_marker

    def marker_get(self, event: Dict[str, Any]) -> Dict[str, Any]:
        """
        Recupera i marker e produce la risposta per API Gateway.

        :param event: Evento AWS Lambda (non utilizzato ma previsto dall'UML).
        :return: Dizionario compatibile con API Gateway (statusCode, headers, body).
        """
        try:
            markers = self._get_marker.get_all_markers()
            body = [marker.to_dict() for marker in markers]
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