import json
from unittest.mock import MagicMock, patch

import pytest

from src.materials.repository.s3_resources_repository import S3ResourcesRepository


class TestS3ResourcesRepository:
    """Test per la classe S3ResourcesRepository."""

    @pytest.fixture
    def mock_s3_client(self):
        """Fornisce un mock del client S3 di boto3."""
        with patch("src.materials.repository.s3_resources_repository.boto3") as mock_boto3:
            mock_client = MagicMock()
            mock_boto3.client.return_value = mock_client
            yield mock_client

    @pytest.fixture
    def repository(self, mock_s3_client):
        """Fornisce un'istanza del repository configurato con il mock S3."""
        return S3ResourcesRepository(bucket_name="test-bucket", file_key="test-key.json")

    def test_init_imposta_variabili_correttamente(self, repository):
        """Verifica che il costruttore imposti bucket e key correttamente."""
        assert repository._bucket_name == "test-bucket"
        assert repository._file_key == "test-key.json"

    def test_list_all_resources_ritorna_lista(self, repository, mock_s3_client):
        """Verifica che list_all_resources decodifichi e restituisca una lista di Resource."""
        fake_json_data = [
            {
                "resource_id": "1",
                "title": "Title 1",
                "content": "Content 1",
                "url": "https://example.com/1",
                "type": "LAW",
            },
            {
                "resource_id": "2",
                "title": "Title 2",
                "content": "Content 2",
                "url": "https://example.com/2",
                "type": "ARTICLE",
            },
        ]
        
        mock_response = {
            "Body": MagicMock()
        }
        mock_response["Body"].read.return_value.decode.return_value = json.dumps(fake_json_data)
        mock_s3_client.get_object.return_value = mock_response

        result = repository.list_all_resources()

        assert len(result) == 2
        assert result[0]._resource_id == "1"
        assert result[0]._title == "Title 1"
        assert result[1]._resource_id == "2"
        
        mock_s3_client.get_object.assert_called_once_with(Bucket="test-bucket", Key="test-key.json")

    def test_list_all_resources_solleva_eccezione_su_errore_s3(self, repository, mock_s3_client):
        """Verifica che list_all_resources propaga le eccezioni di S3."""
        mock_s3_client.get_object.side_effect = Exception("S3 Error")

        with pytest.raises(Exception) as excinfo:
            repository.list_all_resources()
            
        assert "S3 Error" in str(excinfo.value)
