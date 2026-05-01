import json
import pytest

from conftest import build_event

def test_add_note_with_media(controller, aws_s3_client):
    body = {
        "title": "Note with image",
        "created_at": "2025",
        "last_modified_at": "2025",
        "diary_type": "PERSONAL",
        "elements": [
            {"type": "image", "content": "fake"}
        ]
    }

    event = build_event("PUT /note", body)
    response = controller.handle_request(event, {})

    assert response["statusCode"] == 201
    body = json.loads(response["body"])

    assert "note_id" in body
    assert len(body["upload_urls"]) == 1

    upload = body["upload_urls"][0]
    assert "upload_url" in upload
    assert upload["upload_url"].startswith("https://")


def test_get_note_with_media(controller):
    # crea nota con immagine
    create = controller.handle_request(build_event("PUT /note", {
        "title": "Note",
        "created_at": "2025",
        "last_modified_at": "2025",
        "diary_type": "PERSONAL",
        "elements": [{"type": "image", "content": "x"}]
    }), {})

    note_id = json.loads(create["body"])["note_id"]

    # get
    event = build_event("GET /notes/{note_id}", {
        "note_id": note_id,
        "diary_type": "PERSONAL"
    })

    response = controller.handle_request(event, {})
    assert response["statusCode"] == 200

    body = json.loads(response["body"])

    # verifica che abbia elementi
    assert "message_elements" in body


def test_delete_note_removes_s3_objects(controller, aws_s3_client):
    # crea nota con media
    create = controller.handle_request(build_event("PUT /note", {
        "title": "Delete test",
        "created_at": "2025",
        "last_modified_at": "2025",
        "diary_type": "PERSONAL",
        "elements": [{"type": "image", "content": "x"}]
    }), {})

    note_id = json.loads(create["body"])["note_id"]

    # aggiungiamo manualmente oggetto S3 (simuliamo upload)
    key = f"user1/{note_id}/fake_element"
    aws_s3_client.put_object(
        Bucket="test-bucket",
        Key=key,
        Body=b"test"
    )

    # delete note
    delete_event = build_event("DELETE /notes/{note_id}", {
        "note_id": note_id,
        "diary_type": "PERSONAL"
    })

    controller.handle_request(delete_event, {})

    # verifica che oggetto NON esista più
    response = aws_s3_client.list_objects_v2(Bucket="test-bucket")

    keys = [obj["Key"] for obj in response.get("Contents", [])]

    assert key not in keys


def test_add_note_element_with_media(controller):
    create = controller.handle_request(build_event("PUT /note", {
        "title": "Note",
        "created_at": "2025",
        "last_modified_at": "2025",
        "diary_type": "PERSONAL",
        "elements": []
    }), {})

    note_id = json.loads(create["body"])["note_id"]

    event = build_event("PUT note/element", {
        "note_id": note_id,
        "type": "image",
        "content": "x"
    })

    response = controller.handle_request(event, {})

    assert "element_id" in response
    assert "upload_url" in response
    assert response["upload_url"].startswith("https://")


def test_delete_note_element_removes_s3(controller, aws_s3_client):
    create = controller.handle_request(build_event("PUT /note", {
        "title": "Note",
        "created_at": "2025",
        "last_modified_at": "2025",
        "diary_type": "PERSONAL",
        "elements": []
    }), {})

    note_id = json.loads(create["body"])["note_id"]

    add = controller.handle_request(build_event("PUT note/element", {
        "note_id": note_id,
        "type": "image",
        "content": "x"
    }), {})

    element_id = add["element_id"]

    key = f"user1/{note_id}/{element_id}"

    aws_s3_client.put_object(
        Bucket="test-bucket",
        Key=key,
        Body=b"test"
    )

    delete_event = build_event("DELETE note/element", {
        "note_id": note_id,
        "note_element_id": element_id,
        "type": "image",
        "content": key
    })

    controller.handle_request(delete_event, {})

    response = aws_s3_client.list_objects_v2(Bucket="test-bucket")
    keys = [obj["Key"] for obj in response.get("Contents", [])]

    assert key not in keys


def test_user_cannot_access_other_user_note(controller):
    # user1 crea nota
    create = controller.handle_request(build_event("PUT /note", {
        "title": "Secret",
        "created_at": "2025",
        "last_modified_at": "2025",
        "diary_type": "PERSONAL",
        "elements": []
    }, user_id="user1"), {})

    note_id = json.loads(create["body"])["note_id"]

    # user2 prova a leggerla
    event = build_event("GET /notes/{note_id}", {
        "note_id": note_id,
        "diary_type": "PERSONAL"
    }, user_id="user2")

    response = controller.handle_request(event, {})

    assert response["statusCode"] == 200
    body = json.loads(response["body"])
    assert body is None  # oppure errore a seconda della tua logica