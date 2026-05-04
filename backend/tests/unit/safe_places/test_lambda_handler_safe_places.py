from unittest.mock import MagicMock, patch

import pytest

from src.safe_places.lambda_handler import lambda_handler


class TestLambdaHandlerSafePlaces:
    """Test per l'entry point della Lambda function dei luoghi sicuri."""

    @pytest.fixture
    def mock_dependencies(self):
        """Fornisce mock per le dipendenze della Lambda."""
        with patch("src.safe_places.lambda_handler.S3SafePlacesRepository") as mock_repository, \
             patch("src.safe_places.lambda_handler.SafePlacesService") as mock_service, \
             patch("src.safe_places.lambda_handler.SafePlacesController") as mock_controller:
        
            mock_controller_instance = MagicMock()
            mock_controller_instance.marker_get.return_value = {
                "statusCode": 200,
                "body": "[]"
            }
            mock_controller.return_value = mock_controller_instance
            
            yield {
                "repository": mock_repository,
                "service": mock_service,
                "controller": mock_controller,
                "controller_instance": mock_controller_instance
            }

    def test_lambda_handler_innesca_correttamente_i_componenti(self, mock_dependencies):
        """Verifica che l'handler istanzi le classi corrette e chiami il controller."""
        event = {"queryStringParameters": None, "httpMethod": "GET"}
        context = MagicMock()

        response = lambda_handler(event, context)

        mock_dependencies["repository"].assert_called_once_with(
            "app-protegge-trasforma-luoghi-sicuri-mvp", "luoghi-sicuri.json"
        )
        mock_dependencies["service"].assert_called_once_with(
            mock_dependencies["repository"].return_value
        )
        mock_dependencies["controller"].assert_called_once_with(
            mock_dependencies["service"].return_value
        )

        mock_dependencies["controller_instance"].marker_get.assert_called_once_with(event)

        assert response["statusCode"] == 200
        assert response["body"] == "[]"

    def test_lambda_handler_supporta_api_v2_payload(self, mock_dependencies):
        """Verifica che l'handler riconosca il metodo GET in un payload API Gateway v2."""
        event = {
            "requestContext": {
                "http": {
                    "method": "GET"
                }
            }
        }
        context = MagicMock()

        response = lambda_handler(event, context)

        assert response["statusCode"] == 200
        mock_dependencies["controller_instance"].marker_get.assert_called_once_with(event)

    def test_lambda_handler_gestisce_options_preflight(self, mock_dependencies):
        """Verifica che l'handler risponda correttamente alle richieste OPTIONS."""
        event = {"httpMethod": "OPTIONS"}
        context = MagicMock()

        response = lambda_handler(event, context)

        assert response["statusCode"] == 200
        assert response["headers"]["Access-Control-Allow-Origin"] == "*"
        assert "OPTIONS" in response["headers"]["Access-Control-Allow-Methods"]
        assert response["body"] == ""
        # Il controller non dovrebbe essere chiamato per OPTIONS
        mock_dependencies["controller_instance"].marker_get.assert_not_called()

    def test_lambda_handler_rifiuta_metodi_non_supportati(self, mock_dependencies):
        """Verifica che l'handler restituisca 405 per metodi diversi da GET e OPTIONS."""
        event = {"httpMethod": "POST"}
        context = MagicMock()

        response = lambda_handler(event, context)

        assert response["statusCode"] == 405
        assert response["body"] == "Method Not Allowed"
        # Il controller non dovrebbe essere chiamato
        mock_dependencies["controller_instance"].marker_get.assert_not_called()

    def test_lambda_handler_cattura_eccezioni_globali(self, mock_dependencies):
        """Verifica che l'handler catturi le eccezioni e restituisca 500 con traceback."""
        mock_dependencies["controller_instance"].marker_get.side_effect = Exception("Errore imprevisto")
        event = {"httpMethod": "GET"}
        context = MagicMock()

        response = lambda_handler(event, context)

        assert response["statusCode"] == 500
        assert "Unhandled Exception" in response["body"]
        assert "Errore imprevisto" in response["body"]
