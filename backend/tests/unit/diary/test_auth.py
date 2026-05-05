import sys
import os
import json

src_diary_path = os.path.abspath(os.path.join(os.path.dirname(__file__), "../../../src/diary"))
src_path = os.path.abspath(os.path.join(os.path.dirname(__file__), "../../../src"))
backend_path = os.path.abspath(os.path.join(os.path.dirname(__file__), "../../.."))
sys.path.insert(0, src_diary_path)
sys.path.insert(1, src_path)
sys.path.insert(2, backend_path)

modules_to_clean = ["ports", "controller", "repository", "models", "service", "domain", "adapters", "commands", "diary_type", "note_element"]
for mod in list(sys.modules.keys()):
    if any(mod == clean_mod or mod.startswith(clean_mod + ".") for clean_mod in modules_to_clean):
        del sys.modules[mod]

import pytest
import boto3
from moto import mock_aws

from src.diary.adapters.dynamo_auth_adapter import DynamoAuthAdapter
print("=== DEBUG SYS.PATH ===", sys.path[:5])
if 'ports' in sys.modules:
    print("=== DEBUG SYS.MODULES['ports'] ===", sys.modules['ports'])
else:
    print("=== DEBUG SYS.MODULES['ports'] NOT FOUND ===")

if 'commands' in sys.modules:
    print("=== DEBUG SYS.MODULES['commands'] ===", sys.modules['commands'])
else:
    print("=== DEBUG SYS.MODULES['commands'] NOT FOUND ===")

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

        os.environ["TABLE_AUTH_NAME"] = "test-auth-table"
        os.environ["REGION"] = "us-east-1"
        os.environ["HASH_SECRET"] = "test-secret"
        os.environ["PASSWORD_HASH_SECRET"] = "test-secret"

        adapter = DynamoAuthAdapter()
        service = DiaryAuthService(adapter)
        controller = DiaryAccessController(service)

        yield controller


# -------------------------
# HELPERS
# -------------------------
def call(controller, route, body):
    user_id = "user1"
    try:
        data = __import__("json").loads(body)
        if "user_id" in data:
            user_id = data["user_id"]
    except:
        pass
    return controller.handle_request({
        "routekey": route,
        "routeKey": route,
        "requestContext": {
            "authorizer": {
                "jwt": {
                    "claims": {
                        "sub": user_id
                    }
                }
            }
        },
        "body": body
    }, None)


def test_set_real_password(setup_auth_stack):
    controller = setup_auth_stack

    body = __import__("json").dumps({
        "password": "Secret123!",
        "previous_password": "",
        "diary_type": "real_diary"
    })

    res = call(controller, "POST /diary/auth/set_password", body)

    assert res["statusCode"] == 200


# -------------------------
# TEST: SET FAKE PASSWORD
# -------------------------
def test_set_fake_password(setup_auth_stack):
    controller = setup_auth_stack

    res = call(controller, "POST /diary/auth/set_password", __import__("json").dumps({
        "user_id": "user1",
        "password": "Fake12345!",
        "diary_type": "fake_diary"
    }))

    assert res["statusCode"] == 200


# -------------------------
# TEST: REAL != FAKE ENFORCEMENT
# -------------------------
def test_real_fake_must_be_different(setup_auth_stack):
    controller = setup_auth_stack

    call(controller, "POST /diary/auth/set_password", __import__("json").dumps({
        "user_id": "user1",
        "password": "Samepass1!",
        "diary_type": "real_diary"
    }))

    res = call(controller, "POST /diary/auth/set_password", __import__("json").dumps({
        "user_id": "user1",
        "password": "Samepass1!",
        "diary_type": "fake_diary"
    }))

    assert res["statusCode"] in (400, 500)


# -------------------------
# TEST: LOGIN VALID REAL
# -------------------------
def test_login_real(setup_auth_stack):
    controller = setup_auth_stack

    call(controller, "POST /diary/auth/set_password", __import__("json").dumps({
        "user_id": "user1",
        "password": "Realpass1!",
        "diary_type": "real_diary"
    }))

    res = call(controller, "POST /diary/auth/login", __import__("json").dumps({
        "user_id": "user1",
        "password": "Realpass1!"
    }))

    assert res["statusCode"] == 200
    assert __import__("json").loads(res["body"])["diary_type"] == "real_diary"


# -------------------------
# TEST: LOGIN INVALID
# -------------------------
def test_login_invalid(setup_auth_stack):
    controller = setup_auth_stack

    res = call(controller, "POST /diary/auth/login", __import__("json").dumps({
        "user_id": "userX",
        "password": "Wrongpass1!"
    }))

    assert res["statusCode"] == 401


# -------------------------
# TEST: STATUS ENDPOINT
# -------------------------
def test_status(setup_auth_stack):
    controller = setup_auth_stack

    call(controller, "POST /diary/auth/set_password", __import__("json").dumps({
        "user_id": "user1",
        "password": "Realpass1!",
        "diary_type": "real_diary"
    }))

    res = call(controller, "GET /diary/auth/status", __import__("json").dumps({
        "user_id": "user1",
        "diary_type": "real_diary"
    }))

    body = __import__("json").loads(res["body"])

    assert body["has_real_password"] is True
    assert "has_fake_password" in body