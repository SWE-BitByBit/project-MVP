# tests/integration/diary/diary_setup.py
import sys
import os
import json
import pytest
import boto3
from moto import mock_aws

# Setup path per il diario
src_diary_path = os.path.abspath(os.path.join(os.path.dirname(__file__), "../../../src/diary"))
src_path = os.path.abspath(os.path.join(os.path.dirname(__file__), "../../../src"))
backend_path = os.path.abspath(os.path.join(os.path.dirname(__file__), "../../.."))

if src_diary_path not in sys.path: sys.path.insert(0, src_diary_path)
if src_path not in sys.path: sys.path.insert(1, src_path)
if backend_path not in sys.path: sys.path.insert(2, backend_path)

# Hook per risolvere gli import circolari/brevi del diario
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

if not any(isinstance(h, DiaryImportHook) for h in sys.meta_path):
    sys.meta_path.insert(0, DiaryImportHook())

# Helper function
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

# Fixtures
@pytest.fixture(scope="function")
def setup_aws():
    with mock_aws():
        dynamodb = boto3.resource("dynamodb", region_name="us-east-1")
        s3 = boto3.client("s3", region_name="us-east-1")
        
        dynamodb.create_table(
            TableName="diary_notes",
            KeySchema=[{"AttributeName": "user_id", "KeyType": "HASH"}, {"AttributeName": "note_id", "KeyType": "RANGE"}],
            AttributeDefinitions=[{"AttributeName": "user_id", "AttributeType": "S"}, {"AttributeName": "note_id", "AttributeType": "S"}],
            ProvisionedThroughput={"ReadCapacityUnits": 5, "WriteCapacityUnits": 5}
        )
        dynamodb.create_table(
            TableName="diary_elements",
            KeySchema=[{"AttributeName": "note_id", "KeyType": "HASH"}, {"AttributeName": "element_id", "KeyType": "RANGE"}],
            AttributeDefinitions=[{"AttributeName": "note_id", "AttributeType": "S"}, {"AttributeName": "element_id", "AttributeType": "S"}],
            ProvisionedThroughput={"ReadCapacityUnits": 5, "WriteCapacityUnits": 5}
        )
        s3.create_bucket(Bucket="diary-media")
        
        yield {"dynamodb": dynamodb, "s3_client": s3}

@pytest.fixture(scope="function")
def controller(setup_aws):
    from src.diary.diary_note_controller import DiaryNoteController
    from src.diary.services.note_service import NoteService
    from src.diary.adapters.dynamo_note_adapter import DynamoNoteAdapter
    from src.diary.adapters.s3_note_adapter import S3NoteAdapter

    note_repo = DynamoNoteAdapter(setup_aws["dynamodb"])
    file_repo = S3NoteAdapter(setup_aws["s3_client"])
    service = NoteService(note_repo, file_repo)
    return DiaryNoteController(service)



