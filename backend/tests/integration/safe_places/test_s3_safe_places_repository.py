"""
Test di integrazione: S3SafePlacesRepository + S3 (emulato con moto).

Verifica che il repository legga e mappi correttamente i dati
da un bucket S3 simulato.
"""

import json

import boto3
import pytest
from moto import mock_aws

from src.safe_places.repository.s3_safe_places_repository import S3SafePlacesRepository

BUCKET_NAME = "app-protegge-trasforma-luoghi-sicuri-mvp"
FILE_KEY = "luoghi-sicuri.json"
REGION = "eu-south-1"

DATI_FITTIZI = [
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


@pytest.fixture
def aws_credentials(monkeypatch):
    """Imposta credenziali AWS fittizie per moto."""
    monkeypatch.setenv("AWS_ACCESS_KEY_ID", "testing")
    monkeypatch.setenv("AWS_SECRET_ACCESS_KEY", "testing")
    monkeypatch.setenv("AWS_SECURITY_TOKEN", "testing")
    monkeypatch.setenv("AWS_SESSION_TOKEN", "testing")
    monkeypatch.setenv("AWS_DEFAULT_REGION", REGION)


@pytest.fixture
def s3_con_file(aws_credentials):
    """
    Fixture che crea un bucket S3 fittizio (moto) con il file popolato.
    """
    with mock_aws():
        s3 = boto3.client("s3", region_name=REGION)
        s3.create_bucket(
            Bucket=BUCKET_NAME,
            CreateBucketConfiguration={"LocationConstraint": REGION},
        )
        s3.put_object(
            Bucket=BUCKET_NAME,
            Key=FILE_KEY,
            Body=json.dumps(DATI_FITTIZI).encode("utf-8"),
        )
        yield s3


@pytest.fixture
def s3_senza_file(aws_credentials):
    """
    Fixture che crea un bucket S3 fittizio vuoto.
    """
    with mock_aws():
        s3 = boto3.client("s3", region_name=REGION)
        s3.create_bucket(
            Bucket=BUCKET_NAME,
            CreateBucketConfiguration={"LocationConstraint": REGION},
        )
        yield s3


class TestS3SafePlacesRepository:
    """Test di integrazione per il repository S3SafePlacesRepository."""

    def test_list_markers_ritorna_lista(self, s3_con_file):
        """Verifica che list_markers restituisca una lista decodificata correttamente dal mock S3."""
        repository = S3SafePlacesRepository(BUCKET_NAME, FILE_KEY)
        result = repository.list_markers()
        
        assert len(result) == 2
        assert result[0]._marker_id == "1"
        assert result[0]._name == "Nome 1"
        assert result[1]._marker_id == "2"

    def test_list_markers_solleva_eccezione_su_errore_s3(self, s3_senza_file):
        """Verifica che list_markers propaga le eccezioni di S3 quando il file non esiste."""
        repository = S3SafePlacesRepository(BUCKET_NAME, FILE_KEY)

        with pytest.raises(Exception) as excinfo:
            repository.list_markers()
            
        assert "NoSuchKey" in str(excinfo.value)
