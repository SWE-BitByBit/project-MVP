import json
import pytest
from unittest.mock import MagicMock, patch

from src.diary.diary_note_controller import DiaryNoteController
from src.diary.domain.diary_type import DiaryType


@pytest.fixture
def mock_service():
    return MagicMock()


@pytest.fixture
def controller(mock_service):
    return DiaryNoteController(mock_service)


@pytest.fixture
def base_event():
    return {
        "requestContext": {
            "authorizer": {
                "jwt": {
                    "claims": {
                        "sub": "user123"
                    }
                }
            }
        }
    }


def parse_response(response):
    return response["statusCode"], json.loads(response["body"])


def test_response(controller):
    response = controller.response(200, {"test": "ok"})
    status, body = parse_response(response)

    assert status == 200
    assert body == {"test": "ok"}


def test_get_user_id(controller, base_event):
    assert controller._get_user_id(base_event) == "user123"


def test_note_add_success(controller, mock_service, base_event):
    event = {
        **base_event,
        "body": json.dumps({
            "diary_type": DiaryType.REAL_DIARY.value,
            "title": "Test",
            "created_at": "2024-01-01",
            "last_modified_at": "2024-01-01",
            "note_elements": [
                {"type": "text", "content": "hello"}
            ]
        })
    }

    mock_service.add_note.return_value = {"id": "note1"}

    response = controller._note_add(event)
    status, body = parse_response(response)

    assert status == 200
    assert body == {"id": "note1"}
    mock_service.add_note.assert_called_once()


def test_note_add_invalid_diary_type(controller, base_event):
    event = {
        **base_event,
        "body": json.dumps({"diary_type": "invalid"})
    }

    response = controller._note_add(event)
    status, body = parse_response(response)

    assert status == 400
    assert body == {"message": "Invalid diary_type"}


def test_note_add_service_exception(controller, mock_service, base_event):
    event = {
        **base_event,
        "body": json.dumps({
            "diary_type": DiaryType.REAL_DIARY.value
        })
    }

    mock_service.add_note.side_effect = Exception()

    response = controller._note_add(event)
    status, body = parse_response(response)

    assert status == 500
    assert body == {"message": "Internal server error"}


def test_note_get_success(controller, mock_service, base_event):
    event = {
        **base_event,
        "pathParameters": {
            "diary_type": DiaryType.REAL_DIARY.value,
            "note_id": "note1"
        }
    }

    mock_service.get_note.return_value = {"id": "note1"}

    response = controller._note_get(event)
    status, body = parse_response(response)

    assert status == 200
    assert body == {"id": "note1"}


def test_note_get_not_found(controller, mock_service, base_event):
    event = {
        **base_event,
        "pathParameters": {
            "diary_type": DiaryType.REAL_DIARY.value,
            "note_id": "missing"
        }
    }

    mock_service.get_note.return_value = None

    response = controller._note_get(event)
    status, body = parse_response(response)

    assert status == 404
    assert body == {"message": "Note not found"}


def test_note_get_invalid_diary_type(controller, base_event):
    event = {
        **base_event,
        "pathParameters": {
            "diary_type": "invalid",
            "note_id": "note1"
        }
    }

    response = controller._note_get(event)
    status, body = parse_response(response)

    assert status == 400


def test_note_delete_success(controller, mock_service, base_event):
    event = {
        **base_event,
        "pathParameters": {
            "diary_type": DiaryType.REAL_DIARY.value,
            "note_id": "note1"
        }
    }

    mock_service.delete_note.return_value = True

    response = controller._note_delete(event)
    status, body = parse_response(response)

    assert status == 200
    assert body == {"message": "Note deleted successfully"}


def test_note_delete_failure(controller, mock_service, base_event):
    event = {
        **base_event,
        "pathParameters": {
            "diary_type": DiaryType.REAL_DIARY.value,
            "note_id": "note1"
        }
    }

    mock_service.delete_note.return_value = False

    response = controller._note_delete(event)
    status, body = parse_response(response)

    assert status == 500


def test_note_element_add_success(controller, mock_service, base_event):
    event = {
        **base_event,
        "body": json.dumps({
            "note_id": "note1",
            "type": "text",
            "content": "content"
        })
    }

    mock_service.add_note_element.return_value = {"id": "el1"}

    response = controller._note_element_add(event)
    status, body = parse_response(response)

    assert status == 200
    assert body == {"id": "el1"}


def test_note_element_add_missing_fields(controller, base_event):
    event = {
        **base_event,
        "body": json.dumps({})
    }

    response = controller._note_element_add(event)
    status, body = parse_response(response)

    assert status == 400
    assert body == {"message": "Missing required fields"}


def test_note_element_add_value_error(controller, mock_service, base_event):
    event = {
        **base_event,
        "body": json.dumps({
            "note_id": "note1",
            "type": "text"
        })
    }

    mock_service.add_note_element.side_effect = ValueError("Invalid element")

    response = controller._note_element_add(event)
    status, body = parse_response(response)

    assert status == 400
    assert body == {"message": "Invalid element"}


def test_note_element_delete_success(controller, mock_service, base_event):
    event = {
        **base_event,
        "pathParameters": {
            "note_id": "note1",
            "note_element_id": "el1"
        }
    }

    mock_service.delete_note_element.return_value = True

    response = controller._note_element_delete(event)
    status, body = parse_response(response)

    assert status == 200


def test_note_element_delete_not_found(controller, mock_service, base_event):
    event = {
        **base_event,
        "pathParameters": {
            "note_id": "note1",
            "note_element_id": "el1"
        }
    }

    mock_service.delete_note_element.return_value = False

    response = controller._note_element_delete(event)
    status, body = parse_response(response)

    assert status == 404


def test_note_element_delete_missing_fields(controller, base_event):
    event = {
        **base_event,
        "pathParameters": {}
    }

    response = controller._note_element_delete(event)
    status, body = parse_response(response)

    assert status == 400


def test_handle_request_routes(controller):
    controller._note_add = MagicMock(return_value="add")
    controller._note_list = MagicMock(return_value="list")

    assert controller.handle_request({"routeKey": "PUT /notes"}, None) == "add"
    assert controller.handle_request({"routeKey": "GET /notes/{diary_type}"}, None) == "list"