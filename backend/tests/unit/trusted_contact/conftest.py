# tests/integration/conftest.py
import pytest
import boto3
import os
import json
from moto import mock_aws
from unittest.mock import patch


@pytest.fixture(scope="function")
def aws_credentials():
    os.environ["AWS_ACCESS_KEY_ID"] = "testing"
    os.environ["AWS_SECRET_ACCESS_KEY"] = "testing"
    os.environ["AWS_SECURITY_TOKEN"] = "testing"
    os.environ["AWS_SESSION_TOKEN"] = "testing"
    os.environ["AWS_DEFAULT_REGION"] = "us-east-1"
    os.environ["REGION"] = "us-east-1"
    os.environ["DMS_TABLE"] = "dms_table"
    os.environ["TRUSTED_CONTACT_TABLE"] = "trusted_contact_table"
    os.environ["SOURCE_EMAIL"] = "noreply@app.com"


@pytest.fixture(scope="function")
def setup_aws(aws_credentials):
    with mock_aws():

        dynamodb = boto3.resource("dynamodb", region_name="us-east-1")

        # tabella DMS
        dms_table = dynamodb.create_table(
            TableName="dms_table",
            KeySchema=[
                {"AttributeName": "user_id", "KeyType": "HASH"}
            ],
            AttributeDefinitions=[
                {"AttributeName": "user_id", "AttributeType": "S"}
            ],
            BillingMode="PAY_PER_REQUEST"
        )
        dms_table.wait_until_exists()
        dms_table.put_item(
            Item={
                "user_id": "user1",
                "user_email": "user1@gmail.com",
                "user_name": "mario",
                "is_active": True,
                "first_timer": 60,
                "second_timer": 120,
                "email_subject": "Messaggio di emergenza",
                "email_body": "Corpo del messaggio",
                "first_timer_count_down": 60,
                "second_timer_count_down": 120,
            }
        )
        dms_table.put_item(
            Item={
                "user_id": "user3",
                "user_email": "user3@gmail.com",
                "user_name": "luigi",
                "is_active": True,
                "first_timer": 6,
                "second_timer": 16,
                "email_subject": "Messaggio di emergenza",
                "email_body": "Corpo del messaggio",
                "first_timer_count_down": 1,
                "second_timer_count_down": 7,
            }
        )
        dms_table.put_item(
            Item={
                "user_id": "user4",
                "user_email": "user3@gmail.com",
                "user_name": "browser",
                "is_active": True,
                "first_timer": 6,
                "second_timer": 16,
                "email_subject": "Messaggio di emergenza",
                "email_body": "Corpo del messaggio",
                "first_timer_count_down": 0,
                "second_timer_count_down": 0,
            }
        )
        dms_table.put_item(
            Item={
                "user_id": "user6",
                "user_email": "cat@gmail.com",
                "user_name": "cat",
                "is_active": True,
                "first_timer": 6,
                "second_timer": 16,
                "email_subject": "Messaggio di emergenza",
                "email_body": "Corpo del messaggio",
                "first_timer_count_down": 0,
                "second_timer_count_down": 1,
            }
        )

        # tabella contatti fidati
        contact_table = dynamodb.create_table(
            TableName="trusted_contact_table",
            KeySchema=[
                {"AttributeName": "user_id", "KeyType": "HASH"},
                {"AttributeName": "contact_id", "KeyType": "RANGE"},
            ],
            AttributeDefinitions=[
                {"AttributeName": "user_id", "AttributeType": "S"},
                {"AttributeName": "contact_id", "AttributeType": "S"},
            ],
            BillingMode="PAY_PER_REQUEST"
        )
        contact_table.wait_until_exists()
        contact_table.put_item(Item={
            "user_id": "user1",
            "contact_id": "contact1",
            "contact_name": "Tywin",
            "contact_email": "tywin@gmail.com",
            "contact_phone_number": "111 1111 111"
        })
        contact_table.put_item(Item={
            "user_id": "user1",
            "contact_id": "contact2",
            "contact_name": "Cersei",
            "contact_email": "cersei@gmail.com",
            "contact_phone_number": "333 2222 222"
        })
        contact_table.put_item(Item={
            "user_id": "user3",
            "contact_id": "contact3",
            "contact_name": "Jon",
            "contact_email": "jon@gmail.com",
            "contact_phone_number": "333 3333 222"
        })
        contact_table.put_item(Item={
            "user_id": "user6",
            "contact_id": "contact4",
            "contact_name": "Ed",
            "contact_email": "ed@gmail.com",
            "contact_phone_number": "333 3333 222"
        })
        contact_table.put_item(Item={
            "user_id": "user6",
            "contact_id": "contact5",
            "contact_name": "Arya",
            "contact_email": "arya@gmail.com",
            "contact_phone_number": "333 3333 222"
        })

        # SES
        ses_client = boto3.client("ses", region_name="us-east-1")
        ses_client.verify_email_identity(EmailAddress="noreply@app.com")
        ses_client.verify_email_identity(EmailAddress="tywin@gmail.com")
        ses_client.verify_email_identity(EmailAddress="cersei@gmail.com")
        ses_client.verify_email_identity(EmailAddress="user1@gmail.com")

        yield {
            "dynamodb": dynamodb,
            "ses_client": ses_client,
            "dms_table": dms_table,
            "contact_table": contact_table,
        }

@pytest.fixture(scope="function")
def aws_dms_table(setup_aws):
    return setup_aws["dms_table"]


@pytest.fixture(scope="function")
def aws_contact_table(setup_aws):
    return setup_aws["contact_table"]


@pytest.fixture(scope="function")
def aws_ses_client(setup_aws):
    return setup_aws["ses_client"]


@pytest.fixture(scope="function")
def controller(setup_aws):
    # importa qui dentro il mock_aws attivo
    from src.trusted_contact.adapters.dynamo_dms_adapter import DynamoDmsAdapter
    from src.trusted_contact.adapters.dynamo_trusted_contact_adapter import DynamoTrustedContactAdapter
    from src.trusted_contact.adapters.ses_notification_adapter import SesNotificationAdapter
    from src.trusted_contact.services.dms_crud_service import DmsCRUDService
    from src.trusted_contact.services.dms_alert_service import DmsAlertService
    from src.trusted_contact.services.trusted_contact_crud_service import TrustedContactCRUDService
    from src.trusted_contact.services.sos_alert_service import SOSAlertService
    from src.trusted_contact.trusted_contact_controller import TrustedContactController
    
    ses_client = setup_aws["ses_client"]

    dynamo_dms = DynamoDmsAdapter()
    dynamo_contacts = DynamoTrustedContactAdapter()
    ses = SesNotificationAdapter(ses_client=ses_client)

    controller = TrustedContactController()
    controller._dms_crud_service = DmsCRUDService(dynamo_dms)
    controller._dms_alert_service = DmsAlertService(dynamo_contacts, ses, dynamo_dms)
    controller._trusted_contact_crud_service = TrustedContactCRUDService(dynamo_contacts)
    controller._sos_alert_service = SOSAlertService(dynamo_contacts, ses)

    return controller


def build_event(method, path, body=None, user_id="user1",
                user_name="mario", user_email="user1@gmail.com"):
    return {
        "requestContext": {
            "http": {"method": method},
            "authorizer": {
                "jwt": {
                    "claims": {
                        "sub": user_id,
                        "given_name": user_name,
                        "email": user_email
                    }
                }
            }
        },
        "rawPath": path,
        "body": json.dumps(body) if body else None
    }