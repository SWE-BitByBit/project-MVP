# tests/unit/test_dynamo_note_adapter.py
import pytest
import boto3
import os
from moto import mock_aws
from typing import List
from datetime import datetime, timezone

from src.diary.adapters.dynamo_note_adapter import DynamoNoteAdapter
from src.diary.domain.note import Note
from src.diary.domain.note_element import NoteElement
from src.diary.domain.diary_type import DiaryType


@pytest.fixture
def setup_mock_dynamo():
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
            "diary_type": "real_diary",
        })
        note_table.put_item(Item={
            "user_id": "user1",
            "note_id": "note2",
            "title": "Seconda nota",
            "created_at": "2024-01-02T00:00:00+00:00",
            "last_modified_at": "2024-01-02T00:00:00+00:00",
            "diary_type": "fake_diary",
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
            "type": "text",
            "content": "Contenuto elemento 2",
        })

        os.environ["NOTES_TABLE"] = "notes_table"
        os.environ["NOTES_ELEMENTS_TABLE"] = "notes_elements_table"
        os.environ["REGION"] = "us-east-1"

        yield DynamoNoteAdapter()


@pytest.fixture
def note_table(setup_mock_dynamo):
    return boto3.resource("dynamodb", region_name="us-east-1").Table("notes_table")


@pytest.fixture
def note_elements_table(setup_mock_dynamo):
    return boto3.resource("dynamodb", region_name="us-east-1").Table("notes_elements_table")


@pytest.fixture
def sample_note():
    return Note(
        note_id="note3",
        user_id="user1",
        title="Nota di test",
        created_at="2024-01-03T00:00:00+00:00",
        last_modified_at="2024-01-03T00:00:00+00:00",
        diary_type=DiaryType.REAL_DIARY,
        message_elements=[]
    )

@pytest.fixture
def sample_note_with_elements():

    notes_elements: List[NoteElement] = []

    notes_elements.append(
        NoteElement(
            note_id="note3",
            note_element_id="01KQDN2P075NJPVYYHSM9PF8J1",
            type="text",
            content="paragrafo 1",
        )
    )

    notes_elements.append(
        NoteElement(
            note_id="note3",
            note_element_id="01KQDN2P07NT5SS77YZN2KHMYX",
            type="text",
            content="paragrafo 2",
        )
    )

    return Note(
        note_id="note3",
        user_id="user1",
        title="Nota di test",
        created_at="2024-01-03T00:00:00+00:00",
        last_modified_at="2024-01-03T00:00:00+00:00",
        diary_type=DiaryType.REAL_DIARY,
        message_elements=notes_elements
    )

@pytest.fixture
def sample_note_element():
    return NoteElement(
        note_id="note1",
        note_element_id="01ARZ3NDEKTSV4RRFFQ69G5FAX",
        type="text",
        content="Nuovo elemento",
    )


# ------------ add ------------

def test_add_note(setup_mock_dynamo, sample_note, note_table):
    adapter = setup_mock_dynamo
    result = adapter.add(sample_note)
    assert result.note_id == "note3"

    item = note_table.get_item(
        Key={"user_id": "user1", "note_id": "note3"}
    ).get("Item")
    assert item is not None
    assert item["title"] == "Nota di test"
    assert item["diary_type"] == "real_diary"


def test_add_note_with_note_element(setup_mock_dynamo, sample_note_with_elements, note_elements_table):
    adapter = setup_mock_dynamo
    adapter.add(sample_note_with_elements)

    item = note_elements_table.get_item(
        Key={"note_id": "note3", "note_element_id": "01KQDN2P075NJPVYYHSM9PF8J1"}
    ).get("Item")
    assert item is not None
    assert item["note_id"] == "note3"
    assert item["note_element_id"] == "01KQDN2P075NJPVYYHSM9PF8J1"

    item2 = note_elements_table.get_item(
        Key={"note_id": "note3", "note_element_id": "01KQDN2P07NT5SS77YZN2KHMYX"}
    ).get("Item")
    assert item2 is not None
    assert item2["note_id"] == "note3"
    assert item2["note_element_id"] == "01KQDN2P07NT5SS77YZN2KHMYX"


# ------------ get ------------

def test_get_note_with_elements(setup_mock_dynamo):
    adapter = setup_mock_dynamo
    result = adapter.get("user1", "note1", DiaryType.REAL_DIARY)
    assert result is not None
    assert result.note_id == "note1"
    assert result.title == "Prima nota"
    assert len(result.message_elements) == 2


def test_get_note_elements_ordered(setup_mock_dynamo):
    adapter = setup_mock_dynamo
    result = adapter.get("user1", "note1", DiaryType.REAL_DIARY)
    ids = [e.note_element_id for e in result.message_elements]
    assert ids == sorted(ids)


def test_get_note_wrong_diary_type(setup_mock_dynamo):
    adapter = setup_mock_dynamo
    result = adapter.get("user1", "note1", DiaryType.FAKE_DIARY)
    assert result is None


def test_get_note_not_found(setup_mock_dynamo):
    adapter = setup_mock_dynamo
    result = adapter.get("user1", "nonexistent", DiaryType.REAL_DIARY)
    assert result is None


# ------------ list ------------

def test_list_notes_real_diary(setup_mock_dynamo):
    adapter = setup_mock_dynamo
    result = adapter.list("user1", DiaryType.REAL_DIARY)
    assert len(result) == 1
    assert result[0].note_id == "note1"


def test_list_notes_fake_diary(setup_mock_dynamo):
    adapter = setup_mock_dynamo
    result = adapter.list("user1", DiaryType.FAKE_DIARY)
    assert len(result) == 1
    assert result[0].note_id == "note2"


def test_list_notes_empty(setup_mock_dynamo):
    adapter = setup_mock_dynamo
    result = adapter.list("user_no_notes", DiaryType.REAL_DIARY)
    assert result == []


def test_list_notes_no_elements(setup_mock_dynamo):
    adapter = setup_mock_dynamo
    result = adapter.list("user1", DiaryType.REAL_DIARY)
    assert result[0].message_elements == []


# ------------ delete ------------

def test_delete_note(setup_mock_dynamo, note_table, note_elements_table):
    adapter = setup_mock_dynamo
    adapter.delete("user1", "note1", DiaryType.REAL_DIARY)

    item = note_table.get_item(
        Key={"user_id": "user1", "note_id": "note1"}
    ).get("Item")
    assert item is None

    elements = note_elements_table.query(
        KeyConditionExpression="note_id = :nid",
        ExpressionAttributeValues={":nid": "note1"}
    )
    assert elements["Count"] == 0


def test_delete_note_not_found(setup_mock_dynamo):
    adapter = setup_mock_dynamo
    with pytest.raises(KeyError):
        adapter.delete("user1", "nonexistent", DiaryType.REAL_DIARY)


# ------------ add_note_element ------------

def test_add_note_element(setup_mock_dynamo, sample_note_element, note_elements_table):
    adapter = setup_mock_dynamo
    result = adapter.add_note_element("user1", sample_note_element)
    assert result.note_element_id == "01ARZ3NDEKTSV4RRFFQ69G5FAX"

    item = note_elements_table.get_item(
        Key={"note_id": "note1", "note_element_id": "01ARZ3NDEKTSV4RRFFQ69G5FAX"}
    ).get("Item")
    assert item is not None
    assert item["content"] == "Nuovo elemento"


def test_add_note_element_note_not_found(setup_mock_dynamo):
    adapter = setup_mock_dynamo
    element = NoteElement(
        note_id="nonexistent",
        note_element_id="01ARZ3NDEKTSV4RRFFQ69G5FAY",
        type="text",
        content="Contenuto",
    )
    with pytest.raises(ValueError):
        adapter.add_note_element("user1", element)


def test_add_note_element_appended_in_order(setup_mock_dynamo, note_elements_table):
    adapter = setup_mock_dynamo
    new_element = NoteElement(
        note_id="note1",
        note_element_id="01ARZ3NDEKTSV4RRFFQ69G5FAZ",
        type="text",
        content="Elemento finale",
    )
    adapter.add_note_element("user1", new_element)
    
    item = note_elements_table.get_item(
        Key={"note_id": "note1", "note_element_id": "01ARZ3NDEKTSV4RRFFQ69G5FAZ"}
    ).get("Item")
    assert item is not None
    assert item["note_id"] == "note1"
    assert item["note_element_id"] == "01ARZ3NDEKTSV4RRFFQ69G5FAZ"


# ------------ delete_note_element ------------

def test_delete_note_element(setup_mock_dynamo, note_elements_table):
    adapter = setup_mock_dynamo
    adapter.delete_note_element("user1", "note1", "01KQDN3RZ9GFSMP4Q8PRWA1ZQ6")

    item = note_elements_table.get_item(
        Key={"note_id": "note1", "note_element_id": "01ARZ3NDEKTSV4RRFFQ69G5FAV"}
    ).get("Item")
    assert item is None

def test_delete_note_element_not_found(setup_mock_dynamo):
    adapter = setup_mock_dynamo
    with pytest.raises(KeyError):
        adapter.delete_note_element("user1", "note1", "nonexistent_element")


def test_delete_note_element_wrong_user(setup_mock_dynamo):
    adapter = setup_mock_dynamo
    with pytest.raises(ValueError):
        adapter.delete_note_element(
            "wrong_user", "note1", "01ARZ3NDEKTSV4RRFFQ69G5FAV"
        )