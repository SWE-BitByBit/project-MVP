# tests/unit/notes/conftest.py
import sys
import os

src_diary_path = os.path.abspath(os.path.join(os.path.dirname(__file__), "../../../src/diary"))
src_path = os.path.abspath(os.path.join(os.path.dirname(__file__), "../../../src"))
backend_path = os.path.abspath(os.path.join(os.path.dirname(__file__), "../../.."))
sys.path.insert(0, os.path.abspath(os.path.dirname(__file__)))
import conftest
sys.modules['conftest'] = conftest

sys.path.insert(1, src_diary_path)
sys.path.insert(2, src_path)
sys.path.insert(3, backend_path)

class DiaryImportHook:
    def find_spec(self, fullname, path, target=None):
        if fullname == "diary_type":
            import src.diary.domain.diary_type
            sys.modules["diary_type"] = sys.modules["src.diary.domain.diary_type"]
            return sys.modules["diary_type"].__spec__
        if fullname == "note_element":
            import src.diary.domain.note_element
            sys.modules["note_element"] = sys.modules["src.diary.domain.note_element"]
            return sys.modules["note_element"].__spec__
        return None

sys.meta_path.insert(0, DiaryImportHook())

import pytest
import boto3
import json
from moto import mock_aws


@pytest.fixture(scope="function")
def aws_credentials():
    os.environ["AWS_ACCESS_KEY_ID"] = "testing"
    os.environ["AWS_SECRET_ACCESS_KEY"] = "testing"
    os.environ["AWS_SESSION_TOKEN"] = "testing"
    os.environ["AWS_DEFAULT_REGION"] = "us-east-1"
    os.environ["REGION"] = "us-east-1"

    os.environ["NOTES_TABLE"] = "notes_table"
    os.environ["NOTES_ELEMENTS_TABLE"] = "notes_elements_table"
    os.environ["BUCKET_NAME"] = "test-bucket"
    os.environ["S3_BUCKET_NOTES_NAME"] = "test-bucket"


@pytest.fixture(scope="function")
def setup_aws(aws_credentials):
    with mock_aws():
        dynamodb = boto3.resource("dynamodb", region_name="us-east-1")

        note_table = dynamodb.create_table(
            TableName="notes_table",
            KeySchema=[
                {"AttributeName": "user_id", "KeyType": "HASH"},
                {"AttributeName": "note_id", "KeyType": "RANGE"},
            ],
            AttributeDefinitions=[
                {"AttributeName": "user_id", "AttributeType": "S"},
                {"AttributeName": "note_id", "AttributeType": "S"},
            ],
            BillingMode="PAY_PER_REQUEST"
        )
        note_table.wait_until_exists()

        note_elements_table = dynamodb.create_table(
            TableName="notes_elements_table",
            KeySchema=[
                {"AttributeName": "note_id", "KeyType": "HASH"},
                {"AttributeName": "note_element_id", "KeyType": "RANGE"},
            ],
            AttributeDefinitions=[
                {"AttributeName": "note_id", "AttributeType": "S"},
                {"AttributeName": "note_element_id", "AttributeType": "S"},
            ],
            BillingMode="PAY_PER_REQUEST"
        )
        note_elements_table.wait_until_exists()

        note_table.put_item(Item={
            "user_id": "user1",
            "note_id": "note1",
            "title": "Prima nota",
            "created_at": "2024-01-01T00:00:00+00:00",
            "last_modified_at": "2024-01-01T00:00:00+00:00",
            "diary_type": "REAL_DIARY",
        })
        note_table.put_item(Item={
            "user_id": "user1",
            "note_id": "note2",
            "title": "Seconda nota",
            "created_at": "2024-01-02T00:00:00+00:00",
            "last_modified_at": "2024-01-02T00:00:00+00:00",
            "diary_type": "FAKE_DIARY",
        })
        note_table.put_item(Item={
            "user_id": "user1",
            "note_id": "note3",
            "title": "Terza nota",
            "created_at": "2024-01-06T00:00:00+00:00",
            "last_modified_at": "2024-01-12T00:00:00+00:00",
            "diary_type": "FAKE_DIARY",
        })
        
        note_elements_table.put_item(Item={
            "note_id": "note1",
            "note_element_id": "01KQDN3RZ9GFSMP4Q8PRWA1ZQ6",
            "type": "text",
            "content": "Contenuto elemento 1",
        })
        note_elements_table.put_item(Item={
            "note_id": "note1",
            "note_element_id": "01KQDN3RZAG5CYHG2ZZZ4X18D7",
            "type": "image",
            "content": "Contenuto elemento 2",
        })
        note_elements_table.put_item(Item={
            "note_id": "note1",
            "note_element_id": "01KQJ8KH11FRG6AWDCTVFCAP9N",
            "type": "image",
            "content": "user1/note1/01KQJ8KH11FRG6AWDCTVFCAP9N",
        })
        note_elements_table.put_item(Item={
            "note_id": "note1",
            "note_element_id": "01KQJ8KH12FM070AVD0JPERFC2",
            "type": "image",
            "content": "user1/note1/01KQJ8KH12FM070AVD0JPERFC2",
        })

        s3_client = boto3.client("s3", region_name="us-east-1")

        bucket_name = os.environ["BUCKET_NAME"]

        s3_client.create_bucket(Bucket=bucket_name)

        s3_client.put_object(
            Bucket=bucket_name,
            Key="user1/note1/01KQJ8KH11FRG6AWDCTVFCAP9N",
            Body=b"fake content"
        )
        s3_client.put_object(
            Bucket=bucket_name,
            Key="user1/note1/01KQJ8KH12FM070AVD0JPERFC2",
            Body=b"fake content"
        )


        yield {
            "dynamodb": dynamodb,
            "note_table": note_table,
            "elements_table": note_elements_table,
            "s3_client": s3_client,
        }


@pytest.fixture(scope="function")
def aws_notes_table(setup_aws):
    return setup_aws["note_table"]


@pytest.fixture(scope="function")
def aws_elements_table(setup_aws):
    return setup_aws["elements_table"]


@pytest.fixture(scope="function")
def aws_s3_client(setup_aws):
    return setup_aws["s3_client"]


@pytest.fixture(scope="function")
def controller(setup_aws, aws_notes_table, aws_s3_client):
    from src.diary.diary_note_controller import DiaryNoteController
    from src.diary.services.note_service import NoteService
    from src.diary.adapters.dynamo_note_adapter import DynamoNoteAdapter
    from src.diary.adapters.s3_note_adapter import S3NoteAdapter

    note_repo = DynamoNoteAdapter(setup_aws["dynamodb"])
    file_repo = S3NoteAdapter(setup_aws["s3_client"])

    service = NoteService(note_repo, file_repo)

    return DiaryNoteController(service)


def build_event(route, body=None, user_id="user1"):
    return {
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
        "body": json.dumps(body) if body else "{}"
    }