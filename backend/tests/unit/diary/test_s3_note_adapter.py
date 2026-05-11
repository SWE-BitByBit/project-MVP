import os
import pytest
from unittest.mock import MagicMock
from botocore.exceptions import ClientError

from src.diary.adapters.s3_note_adapter import S3NoteAdapter


@pytest.fixture
def mock_s3_client():
    return MagicMock()


@pytest.fixture
def adapter(mock_s3_client):
    os.environ["REGION"] = "us-east-1"
    os.environ["S3_BUCKET_NOTES_NAME"] = "test-bucket"
    return S3NoteAdapter(mock_s3_client)


def test_generate_presigned_url_success(adapter, mock_s3_client):
    mock_s3_client.generate_presigned_url.return_value = "https://test-url"

    result = adapter.generate_presigned_url(
        client_method="put_object",
        params={
            "Bucket": "test-bucket",
            "Key": "test-file"
        }
    )

    assert result == "https://test-url"

    mock_s3_client.generate_presigned_url.assert_called_once_with(
        ClientMethod="put_object",
        Params={
            "Bucket": "test-bucket",
            "Key": "test-file"
        },
        ExpiresIn=3600
    )


def test_generate_presigned_url_custom_expiration(adapter, mock_s3_client):
    mock_s3_client.generate_presigned_url.return_value = "https://test-url"

    result = adapter.generate_presigned_url(
        client_method="get_object",
        params={
            "Bucket": "test-bucket",
            "Key": "file"
        },
        expires_in=1800
    )

    assert result == "https://test-url"

    mock_s3_client.generate_presigned_url.assert_called_once_with(
        ClientMethod="get_object",
        Params={
            "Bucket": "test-bucket",
            "Key": "file"
        },
        ExpiresIn=1800
    )


def test_generate_presigned_url_client_error(adapter, mock_s3_client):
    mock_s3_client.generate_presigned_url.side_effect = ClientError(
        {"Error": {"Message": "Access denied"}},
        "GeneratePresignedUrl"
    )

    with pytest.raises(RuntimeError, match="Failed to generate presigned URL"):
        adapter.generate_presigned_url(
            client_method="put_object",
            params={
                "Bucket": "test-bucket",
                "Key": "file"
            }
        )


def test_delete_object_success(adapter, mock_s3_client):
    adapter.delete_object("test-file")

    mock_s3_client.delete_object.assert_called_once_with(
        Bucket="test-bucket",
        Key="test-file"
    )


def test_delete_object_client_error(adapter, mock_s3_client):
    mock_s3_client.delete_object.side_effect = ClientError(
        {"Error": {"Message": "Object not found"}},
        "DeleteObject"
    )

    with pytest.raises(RuntimeError, match="Error in deleting note element media"):
        adapter.delete_object("missing-file")