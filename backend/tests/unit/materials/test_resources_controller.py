import json
from unittest.mock import MagicMock

import pytest

from src.materials.controller.resources_controller import ResourcesController
from src.materials.models.resource import Resource
from src.materials.models.resource_type import ResourceType


def _crea_risorsa(
    resource_id: str = "res-001",
    title: str = "Guida",
    content: str = "Contenuto",
    url: str = "https://example.com",
    resource_type: ResourceType = ResourceType.ARTICLE,
) -> Resource:
    """Helper per costruire un oggetto Resource di test."""
    return Resource(
        resource_id=resource_id,
        title=title,
        content=content,
        url=url,
        resource_type=resource_type,
    )


class TestResourcesController:
    """Test per la classe ResourcesController."""

    def test_get_resources_status_code_200_in_caso_di_successo(self):
        """Verifica che il controller restituisca statusCode 200 in caso di successo."""
        mock_port = MagicMock()
        mock_port.get_resources.return_value = [_crea_risorsa()]
        controller = ResourcesController(mock_port)

        result = controller.get_resources()

        assert result["statusCode"] == 200

    def test_get_resources_body_e_lista_json(self):
        """Verifica che il body della risposta sia una lista JSON serializzata."""
        mock_port = MagicMock()
        mock_port.get_resources.return_value = [_crea_risorsa()]
        controller = ResourcesController(mock_port)

        result = controller.get_resources()
        body = json.loads(result["body"])

        assert isinstance(body, list)

    def test_get_resources_body_contiene_risorsa(self):
        """Verifica che il body contenga la risorsa restituita dalla porta."""
        risorsa = _crea_risorsa(resource_id="x-99", title="Titolo Test")
        mock_port = MagicMock()
        mock_port.get_resources.return_value = [risorsa]
        controller = ResourcesController(mock_port)

        result = controller.get_resources()
        body = json.loads(result["body"])

        assert body[0]["resource_id"] == "x-99"
        assert body[0]["title"] == "Titolo Test"

    def test_get_resources_header_content_type(self):
        """Verifica che la risposta includa l'header Content-Type corretto."""
        mock_port = MagicMock()
        mock_port.get_resources.return_value = []
        controller = ResourcesController(mock_port)

        result = controller.get_resources()

        assert result["headers"]["Content-Type"] == "application/json"

    def test_get_resources_header_cors(self):
        """Verifica che la risposta includa l'header CORS Access-Control-Allow-Origin."""
        mock_port = MagicMock()
        mock_port.get_resources.return_value = []
        controller = ResourcesController(mock_port)

        result = controller.get_resources()

        assert result["headers"]["Access-Control-Allow-Origin"] == "*"

    def test_get_resources_lista_vuota(self):
        """Verifica la risposta quando la porta non restituisce risorse."""
        mock_port = MagicMock()
        mock_port.get_resources.return_value = []
        controller = ResourcesController(mock_port)

        result = controller.get_resources()
        body = json.loads(result["body"])

        assert result["statusCode"] == 200
        assert body == []

    def test_get_resources_status_code_500_in_caso_di_errore(self):
        """Verifica che il controller restituisca statusCode 500 se la porta solleva un'eccezione."""
        mock_port = MagicMock()
        mock_port.get_resources.side_effect = Exception("Errore interno")
        controller = ResourcesController(mock_port)

        result = controller.get_resources()

        assert result["statusCode"] == 500

    def test_get_resources_body_errore_contiene_messaggio(self):
        """Verifica che il body dell'errore includa il campo errorMessage."""
        mock_port = MagicMock()
        mock_port.get_resources.side_effect = Exception("Connessione fallita")
        controller = ResourcesController(mock_port)

        result = controller.get_resources()
        body = json.loads(result["body"])

        assert "errorMessage" in body
        assert "Connessione fallita" in body["errorMessage"]

    def test_get_resources_invoca_porta_una_volta(self):
        """Verifica che get_resources invochi la porta esattamente una volta."""
        mock_port = MagicMock()
        mock_port.get_resources.return_value = []
        controller = ResourcesController(mock_port)

        controller.get_resources()

        mock_port.get_resources.assert_called_once()
