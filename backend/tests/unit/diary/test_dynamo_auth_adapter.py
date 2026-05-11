import os
import pytest
import hashlib
import hmac
from unittest.mock import MagicMock, patch
from botocore.exceptions import ClientError

from src.diary.adapters.dynamo_auth_adapter import DynamoAuthAdapter
from src.diary.domain.diary_type import DiaryType


@pytest.fixture
def mock_table():
    return MagicMock()


@pytest.fixture
def mock_dynamodb(mock_table):
    dynamodb = MagicMock()
    dynamodb.Table.return_value = mock_table
    return dynamodb


@pytest.fixture
def adapter(mock_dynamodb):
    os.environ["REGION"] = "us-east-1"
    os.environ["TABLE_AUTH_NAME"] = "auth-table"
    os.environ["PASSWORD_HASH_SECRET"] = "test-secret"

    with patch("adapters.dynamo_auth_adapter.boto3.resource", return_value=mock_dynamodb):
        return DynamoAuthAdapter()


def test_hash_password(adapter):
    result = adapter.hash_password("password123", "user1")

    expected = hmac.new(
        b"test-secret:user1",
        b"password123",
        hashlib.sha256
    ).hexdigest()

    assert result == expected


@patch("adapters.dynamo_auth_adapter.secrets.token_urlsafe")
def test_start_session_success(mock_token, adapter, mock_table):
    mock_token.return_value = "generated-token"

    result = adapter.start_session("user1")

    assert result == "generated-token"
    mock_table.update_item.assert_called_once()


def test_start_session_client_error(adapter, mock_table):
    mock_table.update_item.side_effect = ClientError(
        {"Error": {"Message": "error"}},
        "UpdateItem"
    )

    with pytest.raises(RuntimeError, match="Failed to start session"):
        adapter.start_session("user1")


def test_end_session_success(adapter, mock_table):
    adapter.end_session("user1")

    mock_table.update_item.assert_called_once_with(
        Key={"user_id": "user1"},
        UpdateExpression="REMOVE access_token"
    )


def test_end_session_client_error(adapter, mock_table):
    mock_table.update_item.side_effect = ClientError(
        {"Error": {"Message": "error"}},
        "UpdateItem"
    )

    with pytest.raises(RuntimeError, match="Failed to end session"):
        adapter.end_session("user1")


def test_validate_password_real_diary(adapter, mock_table):
    hashed = adapter.hash_password("password", "user1")

    mock_table.get_item.return_value = {
        "Item": {
            "real_password": hashed
        }
    }

    result = adapter.validate_password("password", "user1")

    assert result == DiaryType.REAL_DIARY


def test_validate_password_fake_diary(adapter, mock_table):
    hashed = adapter.hash_password("password", "user1")

    mock_table.get_item.return_value = {
        "Item": {
            "fake_password": hashed
        }
    }

    result = adapter.validate_password("password", "user1")

    assert result == DiaryType.FAKE_DIARY


def test_validate_password_invalid(adapter, mock_table):
    mock_table.get_item.return_value = {
        "Item": {}
    }

    result = adapter.validate_password("wrong", "user1")

    assert result is None


def test_validate_password_user_not_found(adapter, mock_table):
    mock_table.get_item.return_value = {}

    result = adapter.validate_password("password", "user1")

    assert result is None


def test_validate_password_client_error(adapter, mock_table):
    mock_table.get_item.side_effect = ClientError(
        {"Error": {"Message": "error"}},
        "GetItem"
    )

    with pytest.raises(RuntimeError):
        adapter.validate_password("password", "user1")


def test_validate_token_success(adapter, mock_table):
    mock_table.get_item.return_value = {
        "Item": {
            "access_token": "valid-token"
        }
    }

    assert adapter.validate_token("valid-token", "user1") is True


def test_validate_token_invalid(adapter, mock_table):
    mock_table.get_item.return_value = {
        "Item": {
            "access_token": "valid-token"
        }
    }

    assert adapter.validate_token("wrong-token", "user1") is False


def test_validate_token_missing(adapter, mock_table):
    mock_table.get_item.return_value = {
        "Item": {}
    }

    assert adapter.validate_token("token", "user1") is False


def test_validate_token_user_not_found(adapter, mock_table):
    mock_table.get_item.return_value = {}

    assert adapter.validate_token("token", "user1") is False


def test_validate_token_client_error(adapter, mock_table):
    mock_table.get_item.side_effect = ClientError(
        {"Error": {"Message": "error"}},
        "GetItem"
    )

    assert adapter.validate_token("token", "user1") is False


def test_set_password_real_success(adapter, mock_table):
    adapter.get_user_passwords = MagicMock(return_value=None)

    result = adapter.set_password(
        "password",
        "user1",
        DiaryType.REAL_DIARY
    )

    assert result is True
    mock_table.update_item.assert_called_once()


def test_set_password_fake_success(adapter, mock_table):
    adapter.get_user_passwords = MagicMock(return_value=None)

    result = adapter.set_password(
        "password",
        "user1",
        DiaryType.FAKE_DIARY
    )

    assert result is True


def test_set_password_real_same_as_fake(adapter):
    password_hash = adapter.hash_password("password", "user1")

    adapter.get_user_passwords = MagicMock(return_value={
        "fake_password": password_hash
    })

    with pytest.raises(ValueError):
        adapter.set_password("password", "user1", DiaryType.REAL_DIARY)


def test_set_password_fake_same_as_real(adapter):
    password_hash = adapter.hash_password("password", "user1")

    adapter.get_user_passwords = MagicMock(return_value={
        "real_password": password_hash
    })

    with pytest.raises(ValueError):
        adapter.set_password("password", "user1", DiaryType.FAKE_DIARY)


def test_set_password_client_error(adapter, mock_table):
    adapter.get_user_passwords = MagicMock(return_value=None)

    mock_table.update_item.side_effect = ClientError(
        {"Error": {"Message": "error"}},
        "UpdateItem"
    )

    result = adapter.set_password(
        "password",
        "user1",
        DiaryType.REAL_DIARY
    )

    assert result is False


def test_get_user_passwords_success(adapter, mock_table):
    mock_table.get_item.return_value = {
        "Item": {
            "real_password": "real",
            "fake_password": "fake"
        }
    }

    result = adapter.get_user_passwords("user1")

    assert result == {
        "real_password": "real",
        "fake_password": "fake"
    }


def test_get_user_passwords_not_found(adapter, mock_table):
    mock_table.get_item.return_value = {}

    result = adapter.get_user_passwords("user1")

    assert result is None


def test_get_user_passwords_client_error(adapter, mock_table):
    mock_table.get_item.side_effect = ClientError(
        {"Error": {"Message": "error"}},
        "GetItem"
    )

    with pytest.raises(RuntimeError):
        adapter.get_user_passwords("user1")