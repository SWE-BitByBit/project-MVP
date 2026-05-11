import json
import os
import pytest
import boto3
from moto import mock_aws

import diary_fixtures
from src.diary.lambda_handler import lambda_handler


@pytest.fixture(scope="function")
def aws_setup():
    with mock_aws():
        dynamodb = boto3.resource("dynamodb", region_name="us-east-1")
        s3 = boto3.client("s3", region_name="us-east-1")

        auth_table = dynamodb.create_table(
            TableName="test-auth-table",
            KeySchema=[
                {"AttributeName": "user_id", "KeyType": "HASH"}
            ],
            AttributeDefinitions=[
                {"AttributeName": "user_id", "AttributeType": "S"}
            ],
            BillingMode="PAY_PER_REQUEST"
        )
        auth_table.wait_until_exists()

        notes_table = dynamodb.create_table(
            TableName="test-notes-table",
            KeySchema=[
                {"AttributeName": "user_id", "KeyType": "HASH"},
                {"AttributeName": "note_id", "KeyType": "RANGE"}
            ],
            AttributeDefinitions=[
                {"AttributeName": "user_id", "AttributeType": "S"},
                {"AttributeName": "note_id", "AttributeType": "S"}
            ],
            BillingMode="PAY_PER_REQUEST"
        )
        notes_table.wait_until_exists()

        elements_table = dynamodb.create_table(
            TableName="test-elements-table",
            KeySchema=[
                {"AttributeName": "note_id", "KeyType": "HASH"},
                {"AttributeName": "note_element_id", "KeyType": "RANGE"}
            ],
            AttributeDefinitions=[
                {"AttributeName": "note_id", "AttributeType": "S"},
                {"AttributeName": "note_element_id", "AttributeType": "S"}
            ],
            BillingMode="PAY_PER_REQUEST"
        )
        elements_table.wait_until_exists()

        s3.create_bucket(Bucket="test-notes-bucket")

        os.environ["TABLE_AUTH_NAME"] = "test-auth-table"
        os.environ["NOTES_TABLE"] = "test-notes-table"
        os.environ["NOTES_ELEMENTS_TABLE"] = "test-elements-table"
        os.environ["NOTES_BUCKET"] = "test-notes-bucket"
        os.environ["REGION"] = "us-east-1"
        os.environ["HASH_SECRET"] = "test-secret"
        os.environ["PASSWORD_HASH_SECRET"] = "test-secret"

        auth_table.put_item(Item={
            "user_id": "user1",
            "access_token": "valid-token"
        })

        yield {
            "auth_table": auth_table,
            "notes_table": notes_table,
            "elements_table": elements_table
        }


@pytest.fixture
def auth_event():
    return {
        "requestContext": {
            "authorizer": {
                "jwt": {
                    "claims": {
                        "sub": "user1"
                    }
                }
            }
        },
        "headers": {
            "X-Diary-Token": "valid-token"
        }
    }


def parse_response(response):
    body = response["body"]
    if isinstance(body, str):
        body = json.loads(body)
    return response["statusCode"], body


def test_invalid_route():
    event = {"routeKey": "INVALID"}

    response = lambda_handler(event, None)
    status, body = parse_response(response)

    assert status == 400
    assert body["error"] == "Invalid route"


def test_unauthorized_missing_token(aws_setup, auth_event):
    event = {
        **auth_event,
        "routeKey": "GET /notes/real_diary",
        "headers": {}
    }

    response = lambda_handler(event, None)
    status, body = parse_response(response)

    assert status == 401
    assert body["error"] == "Unauthorized"


def test_unauthorized_invalid_token(aws_setup, auth_event):
    event = {
        **auth_event,
        "routeKey": "GET /notes/real_diary",
        "headers": {"X-Diary-Token": "wrong-token"}
    }

    response = lambda_handler(event, None)
    status, body = parse_response(response)

    assert status == 401
    assert body["error"] == "Unauthorized"


def test_list_notes_empty(aws_setup, auth_event):
    event = {
        **auth_event,
        "routeKey": "GET /notes/{diary_type}",
        "pathParameters": {
            "diary_type": "real_diary"
        }
    }

    response = lambda_handler(event, None)
    status, body = parse_response(response)

    assert status == 200
    assert body["notes"] == []


def test_add_note_and_list(aws_setup, auth_event):
    add_event = {
        **auth_event,
        "routeKey": "PUT /notes",
        "body": json.dumps({
            "diary_type": "real_diary",
            "title": "Nota integrazione",
            "created_at": "2024-01-01T00:00:00+00:00",
            "last_modified_at": "2024-01-01T00:00:00+00:00",
            "note_elements": []
        })
    }

    add_response = lambda_handler(add_event, None)
    add_status, add_body = parse_response(add_response)

    assert add_status == 200
    assert "note_id" in add_body

    list_event = {
        **auth_event,
        "routeKey": "GET /notes/{diary_type}",
        "pathParameters": {
            "diary_type": "real_diary"
        }
    }

    list_response = lambda_handler(list_event, None)
    list_status, list_body = parse_response(list_response)

    assert list_status == 200
    assert len(list_body["notes"]) == 1
    assert list_body["notes"][0]["title"] == "Nota integrazione"


def test_get_note(aws_setup, auth_event):
    add_event = {
        **auth_event,
        "routeKey": "PUT /notes",
        "body": json.dumps({
            "diary_type": "real_diary",
            "title": "Test get",
            "created_at": "2024-01-01T00:00:00+00:00",
            "last_modified_at": "2024-01-01T00:00:00+00:00",
            "note_elements": []
        })
    }

    add_response = lambda_handler(add_event, None)
    _, add_body = parse_response(add_response)

    get_event = {
        **auth_event,
        "routeKey": "GET /notes/{diary_type}/{note_id}",
        "pathParameters": {
            "diary_type": "real_diary",
            "note_id": add_body["note_id"]
        }
    }

    response = lambda_handler(get_event, None)
    status, body = parse_response(response)

    assert status == 200
    assert body["title"] == "Test get"


def test_delete_note(aws_setup, auth_event):
    add_event = {
        **auth_event,
        "routeKey": "PUT /notes",
        "body": json.dumps({
            "diary_type": "real_diary",
            "title": "Delete me",
            "created_at": "2024-01-01T00:00:00+00:00",
            "last_modified_at": "2024-01-01T00:00:00+00:00",
            "note_elements": []
        })
    }

    add_response = lambda_handler(add_event, None)
    _, add_body = parse_response(add_response)

    delete_event = {
        **auth_event,
        "routeKey": "DELETE /notes/{diary_type}/{note_id}",
        "pathParameters": {
            "diary_type": "real_diary",
            "note_id": add_body["note_id"]
        }
    }

    response = lambda_handler(delete_event, None)
    status, body = parse_response(response)

    assert status == 200
    assert body["message"] == "Note deleted successfully"


def test_add_note_element(aws_setup, auth_event):
    add_event = {
        **auth_event,
        "routeKey": "PUT /notes",
        "body": json.dumps({
            "diary_type": "real_diary",
            "title": "Con elemento",
            "created_at": "2024-01-01T00:00:00+00:00",
            "last_modified_at": "2024-01-01T00:00:00+00:00",
            "note_elements": []
        })
    }

    add_response = lambda_handler(add_event, None)
    _, add_body = parse_response(add_response)

    element_event = {
        **auth_event,
        "routeKey": "PUT /notes/note_element",
        "body": json.dumps({
            "note_id": add_body["note_id"],
            "type": "text",
            "content": "Elemento test"
        })
    }

    response = lambda_handler(element_event, None)
    status, body = parse_response(response)

    assert status == 200
    assert body["content"] == "Elemento test"


def test_invalid_diary_type(aws_setup, auth_event):
    event = {
        **auth_event,
        "routeKey": "GET /notes/{diary_type}",
        "pathParameters": {
            "diary_type": "invalid"
        }
    }

    response = lambda_handler(event, None)
    status, body = parse_response(response)

    assert status == 400
    assert body["message"] == "Invalid diary_type"