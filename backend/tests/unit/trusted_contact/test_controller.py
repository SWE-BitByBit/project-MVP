import json
import pytest
import boto3

from conftest import build_event

def event_bridge_event():
    return {
        "source": "aws.scheduler",
        "requestContext": {
            "authorizer": {
                "jwt": {
                    "claims": {
                        "sub": "system"
                        }
                    }
                }
        }, 
        "rawPath": ""
    }

def get_sent_emails(ses_client):
    """Recupera le email inviate tramite moto SES."""
    return ses_client.get_send_statistics()["SendDataPoints"]


def get_sent_email_count(ses_client):
    """Conta il totale delle email inviate nella sessione."""
    points = get_sent_emails(ses_client)
    return sum(p.get("DeliveryAttempts", 0) for p in points)

#  --------------- dead man switch crud --------------

def test_create_dms_settings(controller, aws_dms_table):
    event = build_event("POST", "/dms_settings", user_id="user5", user_name="wario", user_email="wario@mail.jp")
    response = controller.handle_request(event, {})
    assert response["statusCode"] == 200
    body = json.loads(response["body"])
    assert body["user_id"] == "user5"

    table = aws_dms_table
    item = table.get_item(Key={"user_id": "user5"}).get("Item")
    assert item["user_email"] == "wario@mail.jp"
    assert item["user_name"] == "wario"


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

def test_update_dms_settings_check_name_email_invariant(controller, aws_dms_table):
    body = {
        "is_active": False,
        "first_timer": 30,
        "second_timer": 60,
        "email_subject": "Nuovo soggetto",
        "email_body": "Nuovo corpo"
    }
    event = build_event("PUT", "/dms_settings", body)
    controller.handle_request(event, {})
    
    table = aws_dms_table
    item = table.get_item(Key={"user_id": "user1"}).get("Item")
    assert item["user_email"] == "user1@gmail.com"
    assert item["user_name"] == "mario"

# ---------- heartbeat ------------

def test_heartbeat(controller, aws_dms_table):
    event = build_event("PUT", "/dms_settings/heartbeat")
    response = controller.handle_request(event, {})
    assert response["statusCode"] == 204
    
    table=aws_dms_table
    item = table.get_item(Key={"user_id": "user1"}).get("Item")
    assert item["first_timer_count_down"] == 60
    assert item["second_timer_count_down"] == 120


def test_heartbeat_reset_count_down(controller, aws_dms_table):
    event = build_event("PUT", "/dms_settings/heartbeat", None, "user3")
    controller.handle_request(event, {})

    table = aws_dms_table
    item = table.get_item(Key={"user_id": "user3"}).get("Item")
    assert item["first_timer_count_down"] == 6
    assert item["second_timer_count_down"] == 16

# ------------ Trusted contact ------------

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
    assert len(body["trusted_contacts"]) == 2


def test_update_trusted_contact(controller, aws_contact_table):
    body = {
        "contact_id": "contact1",
        "contact_name": "Tywin Lannister",
        "contact_email": "tywin.lannister@gmail.com",
        "contact_phone_number": "111 0000 000"
    }
    event = build_event("PUT", "/trusted_contact", body)
    response = controller.handle_request(event, {})
    assert response["statusCode"] == 200

    item = aws_contact_table.get_item(
        Key={"user_id": "user1", "contact_id": "contact1"}
    ).get("Item")
    assert item["contact_name"] == "Tywin Lannister"
    assert item["contact_email"] == "tywin.lannister@gmail.com"


def test_delete_trusted_contact(controller):
    event = build_event("DELETE", "/trusted_contact/contact2")
    response = controller.handle_request(event, {})
    assert response["statusCode"] == 200

    get_event = build_event("GET", "/trusted_contact/contact2")
    get_response = controller.handle_request(get_event, {})
    assert get_response["statusCode"] == 500


def test_delete_trusted_contact_not_found(controller):
    event = build_event("DELETE", "/trusted_contact/nonexistent")
    response = controller.handle_request(event, {})
    assert response["statusCode"] == 500

# --------- Alert SOS ---------


def test_send_alert_with_location(controller, aws_ses_client):
    body = {"latitude": 45.4654, "longitude": 9.1859}
    event = build_event("PUT", "/alert", body)
    response = controller.handle_request(event, {})
    assert response["statusCode"] == 200
    assert get_sent_email_count(aws_ses_client) == 2


def test_send_alert_no_location(controller, aws_ses_client):
    body = {}
    event = build_event("PUT", "/alert", body)
    response = controller.handle_request(event, {})
    assert response["statusCode"] == 200
    assert get_sent_email_count(aws_ses_client) == 2


def test_send_alert_no_contacts(controller, aws_ses_client):
    event = build_event("PUT", "/alert", {}, user_id="user_no_contacts",
                        user_email="noone@gmail.com")
    response = controller.handle_request(event, {})
    assert response["statusCode"] == 400
    assert get_sent_email_count(aws_ses_client) == 0

# --------- Scheduler -------------

def test_scheduled_event_decrements_counters_check_user1(controller, aws_dms_table):
    event = event_bridge_event()
    response = controller.handle_request(event, {})
    assert response["statusCode"] == 200

    item = aws_dms_table.get_item(Key={"user_id": "user1"}).get("Item")
    assert int(item["first_timer_count_down"]) == 59
    assert int(item["second_timer_count_down"]) == 119

def test_scheduled_event_decrements_counters_check_user3(controller, aws_dms_table):
    event = event_bridge_event()
    response = controller.handle_request(event, {})
    assert response["statusCode"] == 200

    item_user_3 = aws_dms_table.get_item(Key={"user_id": "user3"}).get("Item")
    assert int(item_user_3["first_timer_count_down"]) == 0
    assert int(item_user_3["second_timer_count_down"]) == 6


def test_scheduled_event_decrements_counters_check_user4(controller, aws_dms_table):
    event = event_bridge_event()
    response = controller.handle_request(event, {})
    assert response["statusCode"] == 200

    item_user_4 = aws_dms_table.get_item(Key={"user_id": "user4"}).get("Item")
    assert int(item_user_4["first_timer_count_down"]) == 0
    assert int(item_user_4["second_timer_count_down"]) == 0


def test_scheduled_event_sends_user_email(controller, aws_ses_client):
    event = event_bridge_event()
    controller.handle_request(event, {})

    assert get_sent_email_count(aws_ses_client) == 3


# -------------- Auth e routing ---------------

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