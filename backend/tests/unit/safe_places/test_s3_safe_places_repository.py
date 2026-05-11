import json
from unittest.mock import MagicMock, patch

import pytest

from src.safe_places.repository.s3_safe_places_repository import S3SafePlacesRepository


class TestS3SafePlacesRepository:
    """Test per la classe S3SafePlacesRepository."""

    @pytest.fixture
    def mock_s3_client(self):
        """Fornisce un mock del client S3 di boto3."""
        with patch("src.safe_places.repository.s3_safe_places_repository.boto3") as mock_boto3:
            mock_client = MagicMock()
            mock_boto3.client.return_value = mock_client
            yield mock_client

    @pytest.fixture
    def repository(self, mock_s3_client):
        """Fornisce un'istanza del repository configurato con il mock S3."""
        return S3SafePlacesRepository(bucket_name="test-bucket", file_key="test-key.json")

    def test_init_imposta_variabili_correttamente(self, repository):
        """Verifica che il costruttore imposti bucket e key correttamente."""
        assert repository._bucket_name == "test-bucket"
        assert repository._file_key == "test-key.json"

    def test_list_markers_ritorna_lista(self, repository, mock_s3_client):
        """Verifica che list_markers decodifichi e restituisca una lista di Marker."""
        fake_json_data = [
            {
                "marker_id": "1",
                "name": "Nome 1",
                "address": "Indirizzo 1",
                "latitude": "45.0",
                "longitude": "11.0",
                "category": "ospedale",
            },
            {
                "marker_id": "2",
                "name": "Nome 2",
                "address": "Indirizzo 2",
                "latitude": "46.0",
                "longitude": "12.0",
                "category": "polizia",
            },
        ]
        
        mock_response = {
            "Body": MagicMock()
        }
        mock_response["Body"].read.return_value.decode.return_value = json.dumps(fake_json_data)
        mock_s3_client.get_object.return_value = mock_response

        result = repository.list_markers()

        assert len(result) == 2
        assert result[0]._marker_id == "1"
        assert result[0]._name == "Nome 1"
        assert result[1]._marker_id == "2"
        
        mock_s3_client.get_object.assert_called_once_with(Bucket="test-bucket", Key="test-key.json")

    def test_list_markers_solleva_eccezione_su_errore_s3(self, repository, mock_s3_client):
        """Verifica che list_markers propaga le eccezioni di S3."""
        mock_s3_client.get_object.side_effect = Exception("S3 Error")

        with pytest.raises(Exception) as excinfo:
            repository.list_markers()
            
        assert "S3 Error" in str(excinfo.value)
