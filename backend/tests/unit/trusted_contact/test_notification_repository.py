import pytest
import boto3
import os

from moto import mock_aws
from src.trusted_contact.adapters.ses_notification_adapter import SesNotificationAdapter
from src.trusted_contact.domain.email_message import AlertMessage, DmsMessage


@pytest.fixture
def setup_mock_ses():
    with mock_aws():
        ses_client = boto3.client("ses", region_name="us-east-1")

        ses_client.verify_email_identity(EmailAddress="user1@gmail.com")
        ses_client.verify_email_identity(EmailAddress="user2@gmail.com")
        ses_client.verify_email_identity(EmailAddress="user3@gmail.com")

        os.environ["REGION"] = "us-east-1"
        os.environ["SOURCE_EMAIL"] = "prova@bitibybit.com"

        yield SesNotificationAdapter(ses_client=ses_client)


@pytest.fixture
def alert_message():
    return AlertMessage(
        source_email="prova@bitibybit.com",
        destination_contact_email="contact@gmail.com",
        subject="Messaggio di emergenza",
        body="Corpo del messaggio di emergenza"
    )


def test_send_alert_message(setup_mock_ses, alert_message):
    adapter = setup_mock_ses
    message_id = adapter.send_email_message(alert_message)

    assert message_id is not None
    assert isinstance(message_id, str)


def test_send_email_wrong_source(setup_mock_ses, alert_message):
    adapter = setup_mock_ses
    alert_message.source_email = "unverified@gmail.com"

    with pytest.raises(RuntimeError):
        adapter.send_email_message(alert_message)


def test_send_email_wrong_destination(setup_mock_ses, alert_message):
    adapter = setup_mock_ses
    alert_message.destination_contact_email = "unverified@gmail.com"

    with pytest.raises(RuntimeError):
        adapter.send_email_message(alert_message)