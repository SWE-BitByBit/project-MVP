import pytest
import boto3
import os
from moto import mock_aws

from src.diary.adapters.s3_note_adapter import S3NoteAdapter

@pytest.fixture
def s3_setup():
    with mock_aws():

        os.environ["S3_BUCKET_NOTES_NAME"] = "test-bucket"

        s3 = boto3.client("s3", region_name="us-east-1")
        s3.create_bucket(Bucket="test-bucket")
        adapter = S3NoteAdapter(s3)

        yield adapter, s3

def test_delete_object_with_moto(s3_setup):

    adapter, s3 = s3_setup
    s3.put_object(
        Bucket="test-bucket",
        Key="file.jpg",
        Body=b"test"
    )
    adapter.delete_object("file.jpg")
    response = s3.list_objects_v2(Bucket="test-bucket")
    contents = response.get("Contents", [])

    assert len(contents) == 0

