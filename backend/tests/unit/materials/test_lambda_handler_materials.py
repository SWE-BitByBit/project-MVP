import json
import boto3
import pytest
from moto import mock_aws

from materials.lambda_handler import lambda_handler

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
    monkeypatch.setenv("AWS_ACCESS_KEY_ID", "testing")
    monkeypatch.setenv("AWS_SECRET_ACCESS_KEY", "testing")
    monkeypatch.setenv("AWS_SECURITY_TOKEN", "testing")
    monkeypatch.setenv("AWS_SESSION_TOKEN", "testing")
    monkeypatch.setenv("AWS_DEFAULT_REGION", REGION)


@pytest.fixture
def s3_popolato(aws_credentials):
    with mock_aws():
        s3 = boto3.client("s3", region_name="us-east-1")

        # NOTE: con moto NON usare CreateBucketConfiguration per regioni non us-east-1
        s3.create_bucket(Bucket=BUCKET_NAME)

        s3.put_object(
            Bucket=BUCKET_NAME,
            Key=FILE_KEY,
            Body=json.dumps(DATI_FITTIZI).encode("utf-8"),
        )
        yield


@pytest.fixture
def s3_vuoto(aws_credentials):
    with mock_aws():
        s3 = boto3.client("s3", region_name="us-east-1")
        s3.create_bucket(Bucket=BUCKET_NAME)
        yield


class TestLambdaHandler:

    def test_status_code_200_successo(self, s3_popolato):
        result = lambda_handler({}, {})
        assert result["statusCode"] == 200

    def test_body_e_lista(self, s3_popolato):
        result = lambda_handler({}, {})
        body = json.loads(result["body"])
        assert isinstance(body, list)

    def test_numero_risorse(self, s3_popolato):
        result = lambda_handler({}, {})
        body = json.loads(result["body"])
        assert len(body) == 2

    def test_primo_elemento_resource_id(self, s3_popolato):
        result = lambda_handler({}, {})
        body = json.loads(result["body"])
        assert body[0]["resource_id"] == "res-001"

    def test_primo_elemento_title(self, s3_popolato):
        result = lambda_handler({}, {})
        body = json.loads(result["body"])
        assert body[0]["title"] == "Guida alla sicurezza"

    def test_primo_elemento_type(self, s3_popolato):
        result = lambda_handler({}, {})
        body = json.loads(result["body"])
        assert body[0]["type"] == "ARTICLE"

    def test_headers_content_type(self, s3_popolato):
        result = lambda_handler({}, {})
        assert result["headers"]["Content-Type"] == "application/json"

    def test_headers_cors(self, s3_popolato):
        result = lambda_handler({}, {})
        assert result["headers"]["Access-Control-Allow-Origin"] == "*"

    def test_status_code_500_file_assente(self, s3_vuoto):
        result = lambda_handler({}, {})
        assert result["statusCode"] == 500

    def test_body_errore_contiene_errorMessage(self, s3_vuoto):
        result = lambda_handler({}, {})
        body = json.loads(result["body"])
        assert "errorMessage" in body