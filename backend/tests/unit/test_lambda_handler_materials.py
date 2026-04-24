import json

import boto3
import pytest
from moto import mock_aws

from src.materials.lambda_handler import lambda_handler

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
def s3_popolato(aws_credentials):
    """Fixture S3 con bucket e file materials.json popolato."""
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
def s3_vuoto(aws_credentials):
    """Fixture S3 con bucket esistente ma senza il file materials.json."""
    with mock_aws():
        s3 = boto3.client("s3", region_name=REGION)
        s3.create_bucket(
            Bucket=BUCKET_NAME,
            CreateBucketConfiguration={"LocationConstraint": REGION},
        )
        yield s3


class TestLambdaHandler:
    """Test di integrazione per lambda_handler."""

    def test_lambda_handler_status_code_200_in_caso_di_successo(self, s3_popolato):
        """Verifica che lambda_handler restituisca 200 quando S3 è raggiungibile e il file esiste."""
        result = lambda_handler({}, {})
        assert result["statusCode"] == 200

    def test_lambda_handler_body_e_lista(self, s3_popolato):
        """Verifica che il body della risposta sia una lista JSON."""
        result = lambda_handler({}, {})
        body = json.loads(result["body"])
        assert isinstance(body, list)

    def test_lambda_handler_numero_risorse(self, s3_popolato):
        """Verifica che il numero di risorse nel body corrisponda ai dati nel file S3."""
        result = lambda_handler({}, {})
        body = json.loads(result["body"])
        assert len(body) == 2

    def test_lambda_handler_primo_elemento_resource_id(self, s3_popolato):
        """Verifica che il resource_id del primo elemento sia corretto."""
        result = lambda_handler({}, {})
        body = json.loads(result["body"])
        assert body[0]["resource_id"] == "res-001"

    def test_lambda_handler_primo_elemento_title(self, s3_popolato):
        """Verifica che il titolo del primo elemento sia corretto."""
        result = lambda_handler({}, {})
        body = json.loads(result["body"])
        assert body[0]["title"] == "Guida alla sicurezza"

    def test_lambda_handler_primo_elemento_type(self, s3_popolato):
        """Verifica che il tipo del primo elemento sia ARTICLE."""
        result = lambda_handler({}, {})
        body = json.loads(result["body"])
        assert body[0]["type"] == "ARTICLE"

    def test_lambda_handler_header_content_type(self, s3_popolato):
        """Verifica che l'header Content-Type sia corretto."""
        result = lambda_handler({}, {})
        assert result["headers"]["Content-Type"] == "application/json"

    def test_lambda_handler_header_cors(self, s3_popolato):
        """Verifica che l'header CORS sia presente."""
        result = lambda_handler({}, {})
        assert result["headers"]["Access-Control-Allow-Origin"] == "*"

    def test_lambda_handler_status_code_500_file_assente(self, s3_vuoto):
        """Verifica che lambda_handler restituisca 500 quando il file materials.json è assente."""
        result = lambda_handler({}, {})
        assert result["statusCode"] == 500

    def test_lambda_handler_body_errore_contiene_error_message(self, s3_vuoto):
        """Verifica che il body contenga il campo errorMessage in caso di errore."""
        result = lambda_handler({}, {})
        body = json.loads(result["body"])
        assert "errorMessage" in body
