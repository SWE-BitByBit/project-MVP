import json
import pytest
from conftest import build_event


def test_create_dms_settings(controller):
    event = build_event("POST", "/dms_settings", user_id="user2")
    response = controller.handle_request(event, {})
    assert response["statusCode"] == 200
    body = json.loads(response["body"])
    assert body["user_id"] == "user2"


def test_get_dms_settings(controller):
    event = build_event("GET", "/dms_settings")
    response = controller.handle_request(event, {})
    assert response["statusCode"] == 200
    body = json.loads(response["body"])
    assert body["user_id"] == "user1"
    assert body["first_timer"] == 60


def test_update_dms_settings(controller):
    body = {
        "is_active": False,
        "first_timer": 30,
        "second_timer": 60,
        "email_subject": "Nuovo soggetto",
        "email_body": "Nuovo corpo"
    }
    event = build_event("PUT", "/dms_settings", body)
    response = controller.handle_request(event, {})
    assert response["statusCode"] == 204


    get_event = build_event("GET", "/dms_settings")
    get_response = controller.handle_request(get_event, {})
    get_body = json.loads(get_response["body"])
    assert get_body["first_timer"] == 30
    assert get_body["email_subject"] == "Nuovo soggetto"


def test_heartbeat(controller):
    event = build_event("PUT", "/dms_settings/heartbeat")
    response = controller.handle_request(event, {})
    assert response["statusCode"] == 204


def test_create_trusted_contact(controller):
    body = {
        "contact_name": "Tyrion",
        "contact_email": "tyrion@gmail.com",
        "contact_phone_number": "333 0000 000"
    }
    event = build_event("POST", "/trusted_contact", body)
    response = controller.handle_request(event, {})
    assert response["statusCode"] == 200
    body = json.loads(response["body"])
    assert body["contact_name"] == "Tyrion"
    assert body["contact_email"] == "tyrion@gmail.com"


def test_get_trusted_contact(controller):
    event = build_event("GET", "/trusted_contact/contact1")
    response = controller.handle_request(event, {})
    assert response["statusCode"] == 200
    body = json.loads(response["body"])
    assert body["contact_id"] == "contact1"
    assert body["contact_name"] == "Tywin"


def test_get_trusted_contact_not_found(controller):
    event = build_event("GET", "/trusted_contact/nonexistent")
    response = controller.handle_request(event, {})
    assert response["statusCode"] == 500


def test_get_all_trusted_contacts(controller):
    event = build_event("GET", "/trusted_contact")
    response = controller.handle_request(event, {})
    assert response["statusCode"] == 200
    body = json.loads(response["body"])
    assert len(body["trusted_contacts"]) >= 2


def test_update_trusted_contact(controller):
    body = {
        "contact_id": "contact1",
        "contact_name": "Tywin Lannister",
        "contact_email": "tywin.lannister@gmail.com",
        "contact_phone_number": "111 0000 000"
    }
    event = build_event("PUT", "/trusted_contact", body)
    response = controller.handle_request(event, {})
    assert response["statusCode"] == 200
    body = json.loads(response["body"])
    assert body["contact_name"] == "Tywin Lannister"


def test_delete_trusted_contact(controller):
    event = build_event("DELETE", "/trusted_contact/contact2")
    response = controller.handle_request(event, {})
    assert response["statusCode"] == 200

    get_event = build_event("GET", "/trusted_contact/contact2")
    get_response = controller.handle_request(get_event, {})
    assert get_response["statusCode"] == 500


def test_send_alert(controller):
    body = {"latitude": 45.4654, "longitude": 9.1859}
    event = build_event("PUT", "/alert", body)
    response = controller.handle_request(event, {})
    assert response["statusCode"] == 200


def test_send_alert_no_location(controller):
    event = build_event("PUT", "/alert")
    response = controller.handle_request(event, {})
    assert response["statusCode"] == 200


def test_unauthorized(controller):
    event = {
        "requestContext": {
            "http": {"method": "GET"},
            "authorizer": {"jwt": {"claims": {}}}
        },
        "rawPath": "/trusted_contact",
        "body": None
    }
    response = controller.handle_request(event, {})
    assert response["statusCode"] == 401


def test_route_not_found(controller):
    event = build_event("GET", "/unknown_route")
    response = controller.handle_request(event, {})
    assert response["statusCode"] == 404


def test_scheduled_event(controller):
    event = {
        "source": "aws.scheduler",
        "requestContext": {
            "authorizer": {"jwt": {"claims": {"sub": "system"}}}
        },
        "rawPath": ""
    }
    response = controller.handle_request(event, {})
    assert response["statusCode"] == 200