import json

import boto3
import pytest
from moto import mock_aws

from materials.models.resource_type import ResourceType
from materials.repository.s3_resources_repository import S3ResourcesRepository

BUCKET_NAME = "app-protegge-trasforma-materials-mvp"
FILE_KEY = "materials.json"
REGION = "eu-south-1"

DATI_FITTIZI = [
    {
        "resource_id": "res-001",
        "title": "Guida alla sicurezza",
        "content": "Contenuto della guida",
        "url": "https://example.com/guida",
        "type": "ARTICLE",
    },
    {
        "resource_id": "res-002",
        "title": "Legge 154/2001",
        "content": "Testo della legge",
        "url": "https://example.com/legge",
        "type": "LAW",
    },
    {
        "resource_id": "res-003",
        "title": "Comunità di supporto",
        "content": "Descrizione comunità",
        "url": "https://example.com/community",
        "type": "COMMUNITY",
    },
]


@pytest.fixture
def s3_con_file(aws_credentials):
    """
    Fixture che crea un bucket S3 fittizio (moto) con il file materials.json popolato.
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
    Fixture che crea un bucket S3 fittizio senza il file materials.json.
    """
    with mock_aws():
        s3 = boto3.client("s3", region_name=REGION)
        s3.create_bucket(
            Bucket=BUCKET_NAME,
            CreateBucketConfiguration={"LocationConstraint": REGION},
        )
        yield s3


@pytest.fixture
def aws_credentials(monkeypatch):
    """Imposta credenziali AWS fittizie per moto."""
    monkeypatch.setenv("AWS_ACCESS_KEY_ID", "testing")
    monkeypatch.setenv("AWS_SECRET_ACCESS_KEY", "testing")
    monkeypatch.setenv("AWS_SECURITY_TOKEN", "testing")
    monkeypatch.setenv("AWS_SESSION_TOKEN", "testing")
    monkeypatch.setenv("AWS_DEFAULT_REGION", REGION)


class TestS3ResourcesRepository:
    """Test per il repository S3ResourcesRepository."""

    def test_list_all_resources_restituisce_lista(self, s3_con_file):
        """Verifica che list_all_resources restituisca una lista."""
        repository = S3ResourcesRepository(BUCKET_NAME, FILE_KEY)
        result = repository.list_all_resources()
        assert isinstance(result, list)

    def test_list_all_resources_numero_elementi(self, s3_con_file):
        """Verifica che il numero di risorse restituite corrisponda ai dati nel file."""
        repository = S3ResourcesRepository(BUCKET_NAME, FILE_KEY)
        result = repository.list_all_resources()
        assert len(result) == 3

    def test_list_all_resources_primo_elemento_resource_id(self, s3_con_file):
        """Verifica che il resource_id del primo elemento sia corretto."""
        repository = S3ResourcesRepository(BUCKET_NAME, FILE_KEY)
        result = repository.list_all_resources()
        assert result[0].to_dict()["resource_id"] == "res-001"

    def test_list_all_resources_primo_elemento_title(self, s3_con_file):
        """Verifica che il titolo del primo elemento sia corretto."""
        repository = S3ResourcesRepository(BUCKET_NAME, FILE_KEY)
        result = repository.list_all_resources()
        assert result[0].to_dict()["title"] == "Guida alla sicurezza"

    def test_list_all_resources_tipo_article(self, s3_con_file):
        """Verifica che il tipo del primo elemento sia ARTICLE."""
        repository = S3ResourcesRepository(BUCKET_NAME, FILE_KEY)
        result = repository.list_all_resources()
        assert result[0].to_dict()["type"] == ResourceType.ARTICLE.value

    def test_list_all_resources_tipo_law(self, s3_con_file):
        """Verifica che il tipo del secondo elemento sia LAW."""
        repository = S3ResourcesRepository(BUCKET_NAME, FILE_KEY)
        result = repository.list_all_resources()
        assert result[1].to_dict()["type"] == ResourceType.LAW.value

    def test_list_all_resources_tipo_community(self, s3_con_file):
        """Verifica che il tipo del terzo elemento sia COMMUNITY."""
        repository = S3ResourcesRepository(BUCKET_NAME, FILE_KEY)
        result = repository.list_all_resources()
        assert result[2].to_dict()["type"] == ResourceType.COMMUNITY.value

    def test_list_all_resources_file_assente_solleva_eccezione(self, s3_senza_file):
        """Verifica che list_all_resources sollevi un'eccezione se il file non esiste."""
        repository = S3ResourcesRepository(BUCKET_NAME, FILE_KEY)
        with pytest.raises(Exception):
            repository.list_all_resources()
