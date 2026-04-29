import pytest
import boto3
import os
from moto import mock_aws

from src.diary.adapters.dynamo_auth_adapter import DynamoAuthAdapter
from src.diary.services.diary_auth_service import DiaryAuthService
from src.diary.diary_access_controller import DiaryAccessController
from src.diary.domain.diary_type import DiaryType


# -------------------------
# FIXTURE DYNAMODB MOCK
# -------------------------
@pytest.fixture
def setup_auth_stack():
    with mock_aws():

        dynamodb = boto3.resource("dynamodb", region_name="us-east-1")

        table = dynamodb.create_table(
            TableName="test-auth-table",
            KeySchema=[
                {"AttributeName": "user_id", "KeyType": "HASH"}
            ],
            AttributeDefinitions=[
                {"AttributeName": "user_id", "AttributeType": "S"}
            ],
            BillingMode="PAY_PER_REQUEST"
        )

        table.wait_until_exists()

        os.environ["DYNAMODB_TABLE_NAME"] = "test-auth-table"
        os.environ["AWS_REGION"] = "us-east-1"
        os.environ["HASH_SECRET"] = "test-secret"

        adapter = DynamoAuthAdapter()
        service = DiaryAuthService(adapter)
        controller = DiaryAccessController(service)

        yield controller


# -------------------------
# HELPERS
# -------------------------
def call(controller, route, body):
    return controller.handle_request({
        "routekey": route,
        "body": body
    }, None)


# -------------------------
# TEST: SET REAL PASSWORD
# -------------------------
def test_set_real_password(setup_auth_stack):
    controller = setup_auth_stack

    res = call(controller, "/diary/auth/set_password", __import__("json").dumps({
        "user_id": "user1",
        "password": "secret123",
        "diary_type": "REAL_DIARY"
    }))

    assert res["statusCode"] == 200


# -------------------------
# TEST: SET FAKE PASSWORD
# -------------------------
def test_set_fake_password(setup_auth_stack):
    controller = setup_auth_stack

    res = call(controller, "/diary/auth/set_password", __import__("json").dumps({
        "user_id": "user1",
        "password": "fake123",
        "diary_type": "FAKE_DIARY"
    }))

    assert res["statusCode"] == 200


# -------------------------
# TEST: REAL != FAKE ENFORCEMENT
# -------------------------
def test_real_fake_must_be_different(setup_auth_stack):
    controller = setup_auth_stack

    call(controller, "/diary/auth/set_password", __import__("json").dumps({
        "user_id": "user1",
        "password": "samepass",
        "diary_type": "REAL_DIARY"
    }))

    res = call(controller, "/diary/auth/set_password", __import__("json").dumps({
        "user_id": "user1",
        "password": "samepass",
        "diary_type": "FAKE_DIARY"
    }))

    assert res["statusCode"] in (400, 500)


# -------------------------
# TEST: LOGIN VALID REAL
# -------------------------
def test_login_real(setup_auth_stack):
    controller = setup_auth_stack

    call(controller, "/diary/auth/set_password", __import__("json").dumps({
        "user_id": "user1",
        "password": "realpass",
        "diary_type": "REAL_DIARY"
    }))

    res = call(controller, "/diary/auth/login", __import__("json").dumps({
        "user_id": "user1",
        "password": "realpass"
    }))

    assert res["statusCode"] == 200
    assert __import__("json").loads(res["body"])["result"] == "real"


# -------------------------
# TEST: LOGIN INVALID
# -------------------------
def test_login_invalid(setup_auth_stack):
    controller = setup_auth_stack

    res = call(controller, "/diary/auth/login", __import__("json").dumps({
        "user_id": "userX",
        "password": "wrong"
    }))

    assert __import__("json").loads(res["body"])["result"] == "invalid"


# -------------------------
# TEST: STATUS ENDPOINT
# -------------------------
def test_status(setup_auth_stack):
    controller = setup_auth_stack

    call(controller, "/diary/auth/set_password", __import__("json").dumps({
        "user_id": "user1",
        "password": "realpass",
        "diary_type": "REAL_DIARY"
    }))

    res = call(controller, "/diary/auth/status", __import__("json").dumps({
        "user_id": "user1",
        "diary_type": "REAL_DIARY"
    }))

    body = __import__("json").loads(res["body"])

    assert body["has_real_password"] is True
    assert "has_fake_password" in body