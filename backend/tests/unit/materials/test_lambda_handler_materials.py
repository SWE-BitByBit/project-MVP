import pytest
from unittest.mock import MagicMock, patch

from src.materials.lambda_handler import lambda_handler

class TestLambdaHandlerMaterials:
    """Test per l'entry point della Lambda function dei materiali."""

    @pytest.fixture
    def mock_dependencies(self):
        """Fornisce mock per le dipendenze della Lambda."""
        with patch("src.materials.lambda_handler.S3ResourcesRepository") as mock_repository, \
             patch("src.materials.lambda_handler.ResourcesService") as mock_service, \
             patch("src.materials.lambda_handler.ResourcesController") as mock_controller:
        
            mock_controller_instance = MagicMock()
            mock_controller_instance.get_resources.return_value = {
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
        event = {}
        context = MagicMock()

        response = lambda_handler(event, context)

        mock_dependencies["repository"].assert_called_once_with(
            "app-protegge-trasforma-materials-mvp", "materials.json"
        )
        mock_dependencies["service"].assert_called_once_with(
            mock_dependencies["repository"].return_value
        )
        mock_dependencies["controller"].assert_called_once_with(
            mock_dependencies["service"].return_value
        )

        mock_dependencies["controller_instance"].get_resources.assert_called_once()

        assert response["statusCode"] == 200
        assert response["body"] == "[]"