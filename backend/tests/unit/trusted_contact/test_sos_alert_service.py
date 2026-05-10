import pytest
from unittest.mock import MagicMock, ANY

from src.trusted_contact.services.sos_alert_service import SOSAlertService
from src.trusted_contact.commands.alert_command import AlertCmd
from src.trusted_contact.domain.trusted_contact import TrustedContact

@pytest.fixture
def mock_contact_repository():
    return MagicMock()

@pytest.fixture
def mock_notification_repository():
    return MagicMock()

@pytest.fixture
def service(mock_contact_repository, mock_notification_repository, monkeypatch):
    monkeypatch.setenv("SOURCE_EMAIL", "noreply@app.com")
    return SOSAlertService(contact_repository=mock_contact_repository, notification_repository=mock_notification_repository)

def test_send_alert_emails_no_contacts(service, mock_contact_repository, mock_notification_repository):
    mock_contact_repository.list.return_value = []
    
    cmd = AlertCmd(user_id="user1", user_name="Mario", latitude=None, longitude=None)
    result = service.send_alert_emails(cmd)
    
    assert result is False
    mock_notification_repository.send_email_message.assert_not_called()

def test_send_alert_emails_with_contacts_no_location(service, mock_contact_repository, mock_notification_repository):
    contact = TrustedContact(user_id="user1", contact_id="c1", contact_name="Luigi", contact_email="luigi@example.com", contact_phone_number="123")
    mock_contact_repository.list.return_value = [contact]
    
    cmd = AlertCmd(user_id="user1", user_name="Mario", latitude=None, longitude=None)
    result = service.send_alert_emails(cmd)
    
    assert result is True
    mock_notification_repository.send_email_message.assert_called_once()
    message = mock_notification_repository.send_email_message.call_args[0][0]
    assert message.destination_contact_email == "luigi@example.com"
    assert message.source_email == "noreply@app.com"
    assert "Posizione non disponibile" in message.body

def test_send_alert_emails_with_contacts_and_location(service, mock_contact_repository, mock_notification_repository):
    contact = TrustedContact(user_id="user1", contact_id="c1", contact_name="Luigi", contact_email="luigi@example.com", contact_phone_number="123")
    mock_contact_repository.list.return_value = [contact]
    
    cmd = AlertCmd(user_id="user1", user_name="Mario", latitude=45.0, longitude=11.0)
    result = service.send_alert_emails(cmd)
    
    assert result is True
    mock_notification_repository.send_email_message.assert_called_once()
    message = mock_notification_repository.send_email_message.call_args[0][0]
    assert message.destination_contact_email == "luigi@example.com"
    assert "https://www.google.com/maps?q=45.0,11.0" in message.body
