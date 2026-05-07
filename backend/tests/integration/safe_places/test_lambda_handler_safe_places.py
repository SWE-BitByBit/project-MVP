"""
Test di integrazione: Lambda Handler safe_places + S3 (emulato con moto).

Verifica che il lambda_handler risponda correttamente leggendo
i dati da un bucket S3 simulato, incluso il caso di errore.
"""

import json
import boto3
import pytest
from moto import mock_aws

from src.safe_places.lambda_handler import lambda_handler

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


class TestLambdaHandlerSafePlaces:

    def test_status_code_200_successo(self, s3_popolato):
        event = {"queryStringParameters": None, "httpMethod": "GET"}
        result = lambda_handler(event, {})
        assert result["statusCode"] == 200

    def test_body_e_lista(self, s3_popolato):
        event = {"queryStringParameters": None, "httpMethod": "GET"}
        result = lambda_handler(event, {})
        body = json.loads(result["body"])
        assert isinstance(body, list)

    def test_numero_risorse(self, s3_popolato):
        event = {"queryStringParameters": None, "httpMethod": "GET"}
        result = lambda_handler(event, {})
        body = json.loads(result["body"])
        assert len(body) == 2

    def test_primo_elemento(self, s3_popolato):
        event = {"queryStringParameters": None, "httpMethod": "GET"}
        result = lambda_handler(event, {})
        body = json.loads(result["body"])
        assert body[0]["marker_id"] == "1"
        assert body[0]["name"] == "Nome 1"

    def test_headers_cors(self, s3_popolato):
        event = {"queryStringParameters": None, "httpMethod": "GET"}
        result = lambda_handler(event, {})
        assert result["headers"]["Access-Control-Allow-Origin"] == "*"

    def test_status_code_500_file_assente(self, s3_vuoto):
        event = {"queryStringParameters": None, "httpMethod": "GET"}
        result = lambda_handler(event, {})
        assert result["statusCode"] == 500

    def test_opzioni_cors(self, s3_popolato):
        event = {"httpMethod": "OPTIONS"}
        result = lambda_handler(event, {})
        assert result["statusCode"] == 200
        assert result["headers"]["Access-Control-Allow-Origin"] == "*"
        assert "OPTIONS" in result["headers"]["Access-Control-Allow-Methods"]
