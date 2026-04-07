import boto3
import json
import pytest
from moto import mock_aws
from uuid import uuid4
from src.hello_world.app import get_contact, lambda_handler

TABLE_NAME = "test-table"
TEST_CONTACT_ID = str(uuid4())
TEST_USER_ID = str(uuid4())


@pytest.fixture
def setUp_mock_dynamo(monkeypatch):
    monkeypatch.setenv("TABLE_NAME", TABLE_NAME)
    with mock_aws():
        dynamodb = boto3.resource("dynamodb", region_name="eu-north-1")
        dynamodb.create_table(
            TableName=TABLE_NAME,
            KeySchema=[
                {"AttributeName": "user_id", "KeyType": "HASH"},
                {"AttributeName": "contact_id", "KeyType": "RANGE"}
            ],
            AttributeDefinitions=[
                {"AttributeName": "user_id", "AttributeType": "S"},
                {"AttributeName": "contact_id", "AttributeType": "S"}
            ],
            BillingMode="PAY_PER_REQUEST",
        )
        table = dynamodb.Table(TABLE_NAME)
        table.put_item(
            Item={
                "user_id": TEST_USER_ID,
                "contact_id": TEST_CONTACT_ID,
                "name": "Luigi",
                "email": "luigi@email.com"
            }
        )
        yield table


def _make_event(contact_id=TEST_CONTACT_ID, sub=TEST_USER_ID):
    return {
        "routeKey": "GET /contacts/{contact_id}",
        "pathParameters": {"contact_id": contact_id},
        "requestContext": {
            "authorizer": {
                "jwt": {
                    "claims": {"sub": sub}
                }
            }
        }
    }


def test_get_contact_found(setUp_mock_dynamo):
    event = _make_event()
    result = get_contact(setUp_mock_dynamo, event)
    assert result["statusCode"] == 200
    body = json.loads(result["body"])
    assert body["contact_id"] == TEST_CONTACT_ID


def test_get_contact_not_found(setUp_mock_dynamo):
    event = _make_event(contact_id=str(uuid4()))  # id che non esiste
    result = get_contact(setUp_mock_dynamo, event)
    assert result["statusCode"] == 404


def test_lambda_handler_get_contact(setUp_mock_dynamo):
    event = _make_event()
    result = lambda_handler(event, {})
    assert result["statusCode"] == 200


def test_lambda_handler_unknown_route(setUp_mock_dynamo):
    event = _make_event()
    event["routeKey"] = "POST /contacts"
    result = lambda_handler(event, {})
    assert result is None
