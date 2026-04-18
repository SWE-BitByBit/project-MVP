import json
import pytest
import boto3
from moto import mock_aws

from src.materials.client import S3Client
from src.materials.material_handler import MaterialHandler, lambda_handler


@pytest.fixture
def mock_s3_env():
    """
    Fixture per preparare l'ambiente virtuale S3 con Moto.
    Crea il bucket e carica un file fittizio.
    """
    with mock_aws():
        s3 = boto3.client("s3", region_name="eu-south-1")
        bucket_name = "app-protegge-trasforma-materials-mvp"
        
        # Crea il bucket
        s3.create_bucket(
            Bucket=bucket_name,
            CreateBucketConfiguration={"LocationConstraint": "eu-south-1"}
        )
        
        # Dati fittizi per il test
        dummy_data = [{"id": 1, "title": "Guida Test"}]
        
        # Popola il file
        s3.put_object(
            Bucket=bucket_name,
            Key="materials.json",
            Body=json.dumps(dummy_data).encode("utf-8")
        )
        yield s3


@pytest.fixture
def mock_s3_env_empty():
    """
    Fixture per un ambiente S3 in cui il bucket esiste ma il file manca.
    """
    with mock_aws():
        s3 = boto3.client("s3", region_name="eu-south-1")
        bucket_name = "app-protegge-trasforma-materials-mvp"
        
        s3.create_bucket(
            Bucket=bucket_name,
            CreateBucketConfiguration={"LocationConstraint": "eu-south-1"}
        )
        yield s3


def test_lambda_success_status_code(mock_s3_env):
    """
    Verifica esclusivamente che lo status code in caso di successo sia 200.
    """
    response = lambda_handler({}, {})
    assert response["statusCode"] == 200


def test_lambda_success_body(mock_s3_env):
    """
    Verifica esclusivamente che il body e i dati json ritornati siano corretti in caso di successo.
    """
    response = lambda_handler({}, {})
    body = json.loads(response["body"])
    
    assert len(body) == 1
    assert body[0]["title"] == "Guida Test"


def test_lambda_error_status_code(mock_s3_env_empty):
    """
    Verifica esclusivamente che lo status code in caso di errore (file non trovato) sia 500.
    """
    response = lambda_handler({}, {})
    assert response["statusCode"] == 500


def test_lambda_error_body(mock_s3_env_empty):
    """
    Verifica esclusivamente che il body riporti un messaggio di errore in caso di fallimento.
    """
    response = lambda_handler({}, {})
    body = json.loads(response["body"])
    
    assert "errorMessage" in body
    assert "NoSuchKey" in body["errorMessage"]
