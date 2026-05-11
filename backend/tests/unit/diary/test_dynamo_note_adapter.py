import pytest
from unittest.mock import MagicMock
from botocore.exceptions import ClientError

from src.diary.adapters.dynamo_note_adapter import DynamoNoteAdapter
from src.diary.domain.note import Note
from src.diary.domain.note_element import NoteElement
from src.diary.domain.diary_type import DiaryType


@pytest.fixture
def mock_dynamodb():
    return MagicMock()


@pytest.fixture
def mock_note_table():
    return MagicMock()


@pytest.fixture
def mock_elements_table():
    return MagicMock()


@pytest.fixture
def adapter(mock_dynamodb, mock_note_table, mock_elements_table):
    mock_dynamodb.Table.side_effect = [mock_note_table, mock_elements_table]

    import os
    os.environ["REGION"] = "us-east-1"
    os.environ["NOTES_TABLE"] = "notes_table"
    os.environ["NOTES_ELEMENTS_TABLE"] = "elements_table"

    return DynamoNoteAdapter(mock_dynamodb)


@pytest.fixture
def sample_note():
    return Note(
        note_id="note1",
        user_id="user1",
        title="Test note",
        created_at="2024-01-01",
        last_modified_at="2024-01-01",
        diary_type=DiaryType.REAL_DIARY,
        message_elements=[]
    )


@pytest.fixture
def sample_note_element():
    return NoteElement(
        note_id="note1",
        note_element_id="el1",
        type="text",
        content="content"
    )


def test_add_note_success(adapter, mock_note_table, sample_note):
    result = adapter.add(sample_note)

    assert result == sample_note
    mock_note_table.put_item.assert_called_once()


def test_add_note_with_elements(adapter, sample_note):
    sample_note.message_elements = [
        NoteElement("note1", "el1", "text", "test")
    ]

    adapter.add_note_element = MagicMock()

    adapter.add(sample_note)

    adapter.add_note_element.assert_called_once()


def test_add_note_client_error(adapter, mock_note_table, sample_note):
    mock_note_table.put_item.side_effect = ClientError(
        {"Error": {"Message": "Error"}},
        "PutItem"
    )

    with pytest.raises(ClientError):
        adapter.add(sample_note)


def test_get_note_success(adapter, mock_note_table):
    mock_note_table.get_item.return_value = {
        "Item": {
            "note_id": "note1",
            "user_id": "user1",
            "title": "Test",
            "created_at": "2024-01-01",
            "last_modified_at": "2024-01-01",
            "diary_type": "real_diary"
        }
    }

    adapter._get_note_elements = MagicMock(return_value=[])

    result = adapter.get("user1", "note1", DiaryType.REAL_DIARY)

    assert result.note_id == "note1"


def test_get_note_not_found(adapter, mock_note_table):
    mock_note_table.get_item.return_value = {}

    result = adapter.get("user1", "note1", DiaryType.REAL_DIARY)

    assert result is None


def test_get_note_wrong_diary_type(adapter, mock_note_table):
    mock_note_table.get_item.return_value = {
        "Item": {
            "diary_type": "fake_diary"
        }
    }

    result = adapter.get("user1", "note1", DiaryType.REAL_DIARY)

    assert result is None


def test_list_notes_success(adapter, mock_note_table):
    mock_note_table.query.return_value = {
        "Items": [
            {
                "note_id": "note1",
                "user_id": "user1",
                "title": "Test",
                "created_at": "2024-01-01",
                "last_modified_at": "2024-01-01",
                "diary_type": "real_diary"
            }
        ]
    }

    result = adapter.list("user1", DiaryType.REAL_DIARY)

    assert len(result) == 1
    assert result[0].note_id == "note1"


def test_list_notes_client_error(adapter, mock_note_table):
    mock_note_table.query.side_effect = ClientError(
        {"Error": {"Message": "Error"}},
        "Query"
    )

    with pytest.raises(RuntimeError):
        adapter.list("user1", DiaryType.REAL_DIARY)


def test_delete_success(adapter):
    adapter.get = MagicMock(return_value=MagicMock())
    adapter._get_note_elements = MagicMock(return_value=[
        NoteElement("note1", "el1", "text", "content")
    ])

    adapter.delete("user1", "note1", DiaryType.REAL_DIARY)

    adapter._note_table.delete_item.assert_called_once()
    adapter._note_elements_table.delete_item.assert_called_once()


def test_delete_note_not_found(adapter):
    adapter.get = MagicMock(return_value=None)

    with pytest.raises(KeyError):
        adapter.delete("user1", "note1", DiaryType.REAL_DIARY)


def test_add_note_element_success(adapter, mock_note_table, mock_elements_table, sample_note_element):
    mock_note_table.get_item.return_value = {
        "Item": {"user_id": "user1"}
    }

    result = adapter.add_note_element("user1", sample_note_element)

    assert result == sample_note_element
    mock_elements_table.put_item.assert_called_once()


def test_add_note_element_unauthorized(adapter, mock_note_table, sample_note_element):
    mock_note_table.get_item.return_value = {}

    with pytest.raises(ValueError):
        adapter.add_note_element("user1", sample_note_element)


def test_delete_note_element_success(adapter):
    adapter.get_note_element = MagicMock()

    adapter.delete_note_element("user1", "note1", "el1")

    adapter._note_elements_table.delete_item.assert_called_once()


def test_get_note_element_success(adapter, mock_note_table, mock_elements_table):
    mock_note_table.get_item.return_value = {
        "Item": {"user_id": "user1"}
    }

    mock_elements_table.get_item.return_value = {
        "Item": {
            "note_id": "note1",
            "note_element_id": "el1",
            "type": "text",
            "content": "content"
        }
    }

    result = adapter.get_note_element("user1", "note1", "el1")

    assert result.note_element_id == "el1"


def test_get_note_element_note_not_found(adapter, mock_note_table):
    mock_note_table.get_item.return_value = {}

    with pytest.raises(ValueError):
        adapter.get_note_element("user1", "note1", "el1")


def test_get_note_element_element_not_found(adapter, mock_note_table, mock_elements_table):
    mock_note_table.get_item.return_value = {
        "Item": {"user_id": "user1"}
    }

    mock_elements_table.get_item.return_value = {}

    with pytest.raises(KeyError):
        adapter.get_note_element("user1", "note1", "el1")


def test_get_note_elements_success(adapter, mock_elements_table):
    mock_elements_table.query.return_value = {
        "Items": [
            {
                "note_id": "note1",
                "note_element_id": "el1",
                "type": "text",
                "content": "content"
            }
        ]
    }

    result = adapter._get_note_elements("note1")

    assert len(result) == 1
    assert result[0].note_element_id == "el1"