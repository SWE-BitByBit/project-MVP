import json
import pytest

from lambda_handler import lambda_handler
from conftest import build_event


class TestLambdaTrustedContactHandler:

    # =========================
    # AUTH / BASE ROUTING
    # =========================

    def test_unauthorized_se_assenza_user_id(self, setup_aws):
        event = build_event("GET", "/trusted_contact", user_id=None)

        result = lambda_handler(event, None)

        assert result["statusCode"] == 401
        body = json.loads(result["body"])
        assert body["message"] == "Unauthorized"

    def test_route_non_esistente_ritorna_404(self, setup_aws):
        event = build_event("GET", "/route_unknown")

        result = lambda_handler(event, None)

        assert result["statusCode"] == 404
        body = json.loads(result["body"])
        assert body["message"] == "Route not found"

    # =========================
    # TRUSTED CONTACT - CREATE
    # =========================

    def test_create_trusted_contact_success(self, setup_aws):
        body = {
            "contact_name": "Robb",
            "contact_email": "robb@example.com",
            "contact_phone_number": "3123333333"
        }

        event = build_event("POST", "/trusted_contact", body=body)

        result = lambda_handler(event, None)

        assert result["statusCode"] == 200
        resp = json.loads(result["body"])

        assert resp["contact_name"] == "Robb"
        assert resp["contact_email"] == "robb@example.com"

    def test_create_trusted_contact_validation_error(self, setup_aws):
        body = {
            "contact_name": "Robb",
            "contact_email": "invalid-email",
            "contact_phone_number": "abc"
        }

        event = build_event("POST", "/trusted_contact", body=body)

        result = lambda_handler(event, None)

        assert result["statusCode"] == 400
        resp = json.loads(result["body"])

        assert resp["message"] == "Validation error"
        assert "errors" in resp

    # =========================
    # TRUSTED CONTACT - GET ALL
    # =========================

    def test_get_all_trusted_contacts(self, setup_aws):
        event = build_event("GET", "/trusted_contact")

        result = lambda_handler(event, None)

        assert result["statusCode"] == 200
        body = json.loads(result["body"])

        assert "trusted_contacts" in body
        assert isinstance(body["trusted_contacts"], list)

    # =========================
    # TRUSTED CONTACT - GET BY ID
    # =========================

    def test_get_trusted_contact_by_id(self, setup_aws):
        event = build_event("GET", "/trusted_contact/contact1")

        result = lambda_handler(event, None)

        assert result["statusCode"] == 200
        body = json.loads(result["body"])

        assert body["contact_id"] == "contact1"

    # =========================
    # TRUSTED CONTACT - UPDATE
    # =========================

    def test_update_trusted_contact_success(self, setup_aws):
        body = {
            "contact_id": "contact1",
            "contact_name": "Tywin updated",
            "contact_email": "tywin@gmail.com",
            "contact_phone_number": "3123333333"
        }

        event = build_event("PUT", "/trusted_contact", body=body)

        result = lambda_handler(event, None)

        assert result["statusCode"] == 200
        resp = json.loads(result["body"])

        assert resp["contact_name"] == "Tywin updated"

    # =========================
    # TRUSTED CONTACT - DELETE
    # =========================

    def test_delete_trusted_contact_success(self, setup_aws):
        event = build_event("DELETE", "/trusted_contact/contact1")

        result = lambda_handler(event, None)

        assert result["statusCode"] == 200
        body = json.loads(result["body"])

        assert "deleted" in body["message"]

    # =========================
    # DMS SETTINGS
    # =========================

    def test_create_dms_settings(self, setup_aws):
        event = build_event("POST", "/dms_settings")

        result = lambda_handler(event, None)

        assert result["statusCode"] == 200

    def test_get_dms_settings(self, setup_aws):
        event = build_event("GET", "/dms_settings")

        result = lambda_handler(event, None)

        assert result["statusCode"] == 200

    def test_update_dms_settings(self, setup_aws):
        body = {
            "is_active": True,
            "first_timer": 10,
            "second_timer": 20,
            "email_subject": "test",
            "email_body": "test body"
        }

        event = build_event("PUT", "/dms_settings", body=body)

        result = lambda_handler(event, None)

        assert result["statusCode"] == 204

    def test_heartbeat(self, setup_aws):
        event = build_event("PUT", "/dms_settings/heartbeat")

        result = lambda_handler(event, None)

        assert result["statusCode"] == 204

    # =========================
    # ALERT
    # =========================

    def test_alert_no_contacts(self, setup_aws):
        # user senza contatti validi può portare a 400
        event = build_event(
            "PUT",
            "/alert",
            body={"latitude": 10, "longitude": 20}
        )

        result = lambda_handler(event, None)

        assert result["statusCode"] == 200

    # =========================
    # SCHEDULER EVENT
    # =========================

    def test_scheduler_event(self, setup_aws):
        event = {
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

        result = lambda_handler(event, None)

        assert result["statusCode"] == 200