import pytest
import boto3
import os
from datetime import datetime, timezone
from moto import mock_aws

from src.diary.adapters.dynamo_note_adapter import DynamoNoteAdapter
from src.diary.domain.note import Note
from src.diary.domain.note_element import NoteElement
from src.diary.domain.diary_type import DiaryType


@pytest.fixture
def setup_mock_dynamo():
    with mock_aws():

        dynamodb = boto3.resource("dynamodb", region_name="us-east-1")
        table = dynamodb.create_table(
            TableName="test-notes-table",
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

        table.wait_until_exists()
        os.environ["TABLE_NOTES_NAME"] = "test-notes-table"
        os.environ["REGION"] = "us-east-1"
        yield DynamoNoteAdapter()

def test_add_and_get_note(setup_mock_dynamo):

    adapter = setup_mock_dynamo
    note = Note(
        note_id="note1",
        user_id="user1",
        title="Test note",
        created_at=datetime.now(timezone.utc).isoformat(),
        last_modified_at=datetime.now(timezone.utc).isoformat(),
        diary_type=DiaryType.REAL_DIARY,
        message_elements=[
            NoteElement(
                note_element_id="element1",
                type="text",
                content="prova test"
            )
        ]
    )
    adapter.add(note)
    result = adapter.get("user1", "note1", DiaryType.REAL_DIARY)

    assert result is not None
    assert result["note_id"] == "note1"
    assert result["title"] == "Test note"
    assert result["message_elements"][0]["content"] == "prova test"


def test_get_note_not_found(setup_mock_dynamo):

    adapter = setup_mock_dynamo
    result = adapter.get("user1", "missing", DiaryType.REAL_DIARY)
    assert result is None


def test_get_note_wrong_diary_type(setup_mock_dynamo):

    adapter = setup_mock_dynamo
    adapter.table.put_item(Item={
        "user_id": "user1",
        "note_id": "note1",
        "title": "Test",
        "created_at": "2026-01-01",
        "last_modified_at": "2026-01-01",
        "diary_type": "REAL_DIARY",
        "message_elements": []
    })
    result = adapter.get("user1", "note1", DiaryType.FAKE_DIARY)
    assert result is None


def test_add_note_element(setup_mock_dynamo):

    adapter = setup_mock_dynamo
    adapter.table.put_item(Item={
        "user_id": "user1",
        "note_id": "note1",
        "title": "Test",
        "created_at": "2026-01-01",
        "last_modified_at": "2026-01-01",
        "diary_type": "REAL_DIARY",
        "message_elements": []
    })
    element = NoteElement(
        note_element_id="el1",
        type="text",
        content="hello"
    )
    adapter.add_note_element("user1", "note1", element)
    result = adapter.get("user1", "note1", DiaryType.REAL_DIARY)
    assert len(result["message_elements"]) == 1
    assert result["message_elements"][0]["content"] == "hello"


def test_delete_note_element(setup_mock_dynamo):

    adapter = setup_mock_dynamo
    adapter.table.put_item(Item={
        "user_id": "user1",
        "note_id": "note1",
        "title": "Test",
        "created_at": "2026-01-01",
        "last_modified_at": "2026-01-01",
        "diary_type": "REAL_DIARY",
        "message_elements": [
            {
                "element_id": "el1",
                "type": "text",
                "content": "ciao"
            }
        ]
    })
    adapter.delete_note_element("user1", "note1", "el1")
    result = adapter.get("user1", "note1", DiaryType.REAL_DIARY)
    assert result["message_elements"] == []