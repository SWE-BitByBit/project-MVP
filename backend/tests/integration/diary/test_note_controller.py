import json
import pytest

from diary_fixtures import build_event, controller, setup_aws, aws_s3_client


def test_get_note_with_media(controller):
    create = controller.handle_request(build_event("PUT /notes", {
        "title": "Note",
        "created_at": "2024-01-01",
        "last_modified_at": "2024-01-01",
        "diary_type": "real_diary",
        "elements": [{"type": "image", "content": ""}]
    }), {})

    note_id = json.loads(create["body"])["note_id"]
    diary_type = "real_diary"

    # get
    event = build_event(f"GET /notes/{diary_type}/{note_id}")

    response = controller.handle_request(event, {})
    assert response["statusCode"] == 200

    body = json.loads(response["body"])

    # verifica che abbia elementi
    assert "note_elements" in body


def test_add_note_with_media(controller, aws_s3_client):
    body = {
        "title": "Note with image",
        "created_at": "2026-05-04T10:00:00Z",
        "last_modified_at": "2026-05-04T10:00:00Z",
        "diary_type": "real_diary",
        "note_elements": [
            {"type": "image", "content": ""}
        ]
    }

    event = build_event("PUT /notes", body)
    response = controller.handle_request(event, {})
    assert response["statusCode"] == 200

    body_response = json.loads(response["body"])
    assert "note_id" in body_response

    upload = body_response["note_elements"][0]
    assert "upload_url" in upload
    assert upload["upload_url"].startswith("https://")


def test_add_note_invalid_diary_type(controller):
    body = {
        "title": "Nota",
        "created_at": "2026-05-04T10:00:00Z",
        "last_modified_at": "2026-05-04T10:00:00Z",
        "diary_type": "tipo_invalido",
        "note_elements": []
    }

    event = build_event("PUT /notes", body)
    response = controller.handle_request(event, {})
    assert response["statusCode"] == 400


def test_get_note_with_media(controller):
    # crea nota con immagine
    create_body = {
        "title": "Note",
        "created_at": "2024-01-01",
        "last_modified_at": "2024-01-01",
        "diary_type": "real_diary",
        "note_elements": [{"type": "image", "content": ""}]
    }
    create = controller.handle_request(build_event("PUT /notes", create_body), {})
    assert create["statusCode"] == 200

    note_id = json.loads(create["body"])["note_id"]

    event = build_event(
        "GET /notes/{diary_type}/{note_id}",
        path_parameters={"diary_type": "real_diary", "note_id": note_id}
    )

    response = controller.handle_request(event, {})
    assert response["statusCode"] == 200

    body = json.loads(response["body"])
    assert "note_id" in body
    assert body["note_id"] == note_id


def test_get_note_not_found(controller):
    event = build_event(
        "GET /notes/{diary_type}/{note_id}",
        path_parameters={"diary_type": "real_diary", "note_id": "nonexistent"}
    )
    response = controller.handle_request(event, {})
    assert response["statusCode"] == 404


def test_get_note_invalid_diary_type(controller):
    event = build_event(
        "GET /notes/{diary_type}/{note_id}",
        path_parameters={"diary_type": "invalid", "note_id": "note1"}
    )
    response = controller.handle_request(event, {})
    assert response["statusCode"] == 400


def test_list_notes(controller):
    # crea due note real_diary
    for i in range(2):
        controller.handle_request(build_event("PUT /notes", {
            "title": f"Nota {i}",
            "created_at": "2026-01-01",
            "last_modified_at": "2026-01-01",
            "diary_type": "real_diary",
            "note_elements": []
        }), {})

    event = build_event(
        "GET /notes/{diary_type}",
        path_parameters={"diary_type": "real_diary"}
    )
    response = controller.handle_request(event, {})
    assert response["statusCode"] == 200

    body = json.loads(response["body"])
    assert "notes" in body
    assert len(body["notes"]) >= 2


def test_list_notes_empty(controller):
    event = build_event(
        "GET /notes/{diary_type}",
        path_parameters={"diary_type": "real_diary"},
        user_id="user_no_notes"
    )
    response = controller.handle_request(event, {})
    assert response["statusCode"] == 200
    body = json.loads(response["body"])
    assert body["notes"] == []


def test_delete_note(controller):
    create = controller.handle_request(build_event("PUT /notes", {
        "title": "Da eliminare",
        "created_at": "2026-01-01",
        "last_modified_at": "2026-01-01",
        "diary_type": "real_diary",
        "note_elements": []
    }), {})

    note_id = json.loads(create["body"])["note_id"]

    delete_event = build_event(
        "DELETE /notes/{diary_type}/{note_id}",
        path_parameters={"diary_type": "real_diary", "note_id": note_id}
    )
    response = controller.handle_request(delete_event, {})
    assert response["statusCode"] == 200

    # verifica che non esista più
    get_event = build_event(
        "GET /notes/{diary_type}/{note_id}",
        path_parameters={"diary_type": "real_diary", "note_id": note_id}
    )
    get_response = controller.handle_request(get_event, {})
    assert get_response["statusCode"] == 404


def test_delete_note_not_found(controller):
    event = build_event(
        "DELETE /notes/{diary_type}/{note_id}",
        path_parameters={"diary_type": "real_diary", "note_id": "nonexistent"}
    )
    response = controller.handle_request(event, {})
    assert response["statusCode"] == 500


def test_add_note_element_text(controller):
    create = controller.handle_request(build_event("PUT /notes", {
        "title": "Nota",
        "created_at": "2026-01-01",
        "last_modified_at": "2026-01-01",
        "diary_type": "real_diary",
        "note_elements": []
    }), {})
    note_id = json.loads(create["body"])["note_id"]

    event = build_event("PUT /notes/note_element", {
        "note_id": note_id,
        "type": "text",
        "content": "Nuovo paragrafo"
    })
    response = controller.handle_request(event, {})
    assert response["statusCode"] == 200

    body = json.loads(response["body"])
    assert "note_element_id" in body
    assert "upload_url" not in body


def test_add_note_element_image(controller):
    create = controller.handle_request(build_event("PUT /notes", {
        "title": "Nota",
        "created_at": "2026-01-01",
        "last_modified_at": "2026-01-01",
        "diary_type": "real_diary",
        "note_elements": []
    }), {})
    note_id = json.loads(create["body"])["note_id"]

    event = build_event("PUT /notes/note_element", {
        "note_id": note_id,
        "type": "image",
        "content": ""
    })
    response = controller.handle_request(event, {})
    assert response["statusCode"] == 200

    body = json.loads(response["body"])
    assert "note_element_id" in body
    assert "upload_url" in body
    assert body["upload_url"].startswith("https://")


def test_delete_note_element(controller):
    create = controller.handle_request(build_event("PUT /notes", {
        "title": "Nota",
        "created_at": "2026-01-01",
        "last_modified_at": "2026-01-01",
        "diary_type": "real_diary",
        "note_elements": []
    }), {})
    note_id = json.loads(create["body"])["note_id"]

    add = controller.handle_request(build_event("PUT /notes/note_element", {
        "note_id": note_id,
        "type": "text",
        "content": "Testo"
    }), {})
    element_id = json.loads(add["body"])["note_element_id"]

    delete_event = build_event(
        "DELETE /notes/note_element/{note_id}/{note_element_id}",
        path_parameters={"note_id": note_id, "note_element_id": element_id}
    )
    response = controller.handle_request(delete_event, {})
    assert response["statusCode"] == 200


def test_delete_note_element_not_found(controller):
    event = build_event(
        "DELETE /notes/note_element/{note_id}/{note_element_id}",
        path_parameters={"note_id": "note1", "note_element_id": "nonexistent"}
    )
    response = controller.handle_request(event, {})
    assert response["statusCode"] == 404


def test_user_cannot_access_other_user_note(controller):
    create = controller.handle_request(build_event("PUT /notes", {
        "title": "Secret",
        "created_at": "2026-01-01",
        "last_modified_at": "2026-01-01",
        "diary_type": "real_diary",
        "note_elements": []
    }, user_id="user1"), {})

    note_id = json.loads(create["body"])["note_id"]

    event = build_event(
        "GET /notes/{diary_type}/{note_id}",
        path_parameters={"diary_type": "real_diary", "note_id": note_id},
        user_id="user2"
    )
    response = controller.handle_request(event, {})
    assert response["statusCode"] == 404