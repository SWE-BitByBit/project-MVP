import json
from unittest.mock import MagicMock

from src.safe_places.controller.safe_places_controller import SafePlacesController
from src.safe_places.models.marker import Marker


class TestSafePlacesController:
    """Test per la classe SafePlacesController."""

    def test_marker_get_successo(self):
        """Verifica che in caso di successo venga restituita la lista serializzata con status 200."""
        mock_service = MagicMock()
        mock_markers = [
            Marker("1", "Nome1", "Indirizzo1", "45", "11", "ospedale"),
        ]
        mock_service.get_all_markers.return_value = mock_markers
        
        controller = SafePlacesController(get_marker=mock_service)
        response = controller.marker_get(event={})
        
        assert response["statusCode"] == 200
        assert response["headers"]["Content-Type"] == "application/json"
        
        body = json.loads(response["body"])
        assert len(body) == 1
        assert body[0]["marker_id"] == "1"
        assert body[0]["name"] == "Nome1"
        
        mock_service.get_all_markers.assert_called_once()

    def test_marker_get_errore(self):
        """Verifica che in caso di errore interno venga restituito status 500 con il messaggio d'errore."""
        mock_service = MagicMock()
        mock_service.get_all_markers.side_effect = Exception("Service error")
        
        controller = SafePlacesController(get_marker=mock_service)
        response = controller.marker_get(event={})
        
        assert response["statusCode"] == 500
        body = json.loads(response["body"])
        assert body["errorMessage"] == "Service error"

    def test_response_helper_formatta_correttamente(self):
        """Verifica che _response costruisca correttamente la mappa di ritorno."""
        controller = SafePlacesController(get_marker=MagicMock())
        resp = controller._response(201, {"message": "ok"})
        
        assert resp["statusCode"] == 201
        assert "headers" in resp
        assert resp["headers"]["Content-Type"] == "application/json"
        assert resp["headers"]["Access-Control-Allow-Origin"] == "*"
        assert resp["body"] == '{"message": "ok"}'
