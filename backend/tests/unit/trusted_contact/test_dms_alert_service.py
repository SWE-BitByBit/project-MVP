import pytest
from unittest.mock import MagicMock, call

from src.trusted_contact.services.dms_alert_service import DmsAlertService
from src.trusted_contact.domain.dms_configuration_settings import DmsConfigurationSettings
from src.trusted_contact.domain.trusted_contact import TrustedContact

@pytest.fixture
def mock_contact_repository():
    return MagicMock()

@pytest.fixture
def mock_notification_repository():
    return MagicMock()

@pytest.fixture
def mock_dms_repository():
    return MagicMock()

@pytest.fixture
def service(mock_contact_repository, mock_notification_repository, mock_dms_repository, monkeypatch):
    monkeypatch.setenv("SOURCE_EMAIL", "noreply@app.com")
    return DmsAlertService(
        contact_repository=mock_contact_repository,
        notification_repository=mock_notification_repository,
        dms_repositopry=mock_dms_repository
    )

def test_update_dms_timers_inactive_config(service, mock_dms_repository):
    config = DmsConfigurationSettings("user1", is_active=False, first_timer=10, second_timer=20, email_subject="", email_body="")
    mock_dms_repository.list_all_configs.return_value = [config]
    
    result = service.update_dms_timers()
    
    assert result is True
    mock_dms_repository.get_first_timer.assert_not_called()

def test_update_dms_timers_decrements_timers(service, mock_dms_repository, mock_notification_repository):
    config = DmsConfigurationSettings("user1", is_active=True, first_timer=10, second_timer=20, email_subject="", email_body="")
    mock_dms_repository.list_all_configs.return_value = [config]
    mock_dms_repository.get_first_timer.return_value = 5
    mock_dms_repository.get_second_timer.return_value = 10
    
    result = service.update_dms_timers()
    
    assert result is True
    mock_dms_repository.update_first_counter.assert_called_once_with("user1", 4)
    mock_dms_repository.update_second_counter.assert_called_once_with("user1", 9)
    mock_notification_repository.send_email_message.assert_not_called()

def test_update_dms_timers_first_timer_reaches_zero(service, mock_dms_repository, mock_notification_repository):
    config = DmsConfigurationSettings("user1", is_active=True, first_timer=10, second_timer=20, email_subject="Sub", email_body="Body")
    mock_dms_repository.list_all_configs.return_value = [config]
    mock_dms_repository.get_first_timer.return_value = 1
    mock_dms_repository.get_second_timer.return_value = 10
    mock_dms_repository.get_user_email.return_value = "user1@example.com"
    
    service.update_dms_timers()
    
    mock_dms_repository.update_first_counter.assert_called_once_with("user1", 0)
    mock_notification_repository.send_email_message.assert_called_once()
    message = mock_notification_repository.send_email_message.call_args[0][0]
    assert message.destination_contact_email == "user1@example.com"
    assert message.subject == "Sub"
    assert message.body == "Body"

def test_update_dms_timers_second_timer_reaches_zero(service, mock_dms_repository, mock_notification_repository, mock_contact_repository):
    config = DmsConfigurationSettings("user1", is_active=True, first_timer=10, second_timer=20, email_subject="", email_body="")
    mock_dms_repository.list_all_configs.return_value = [config]
    mock_dms_repository.get_first_timer.return_value = 0
    mock_dms_repository.get_second_timer.return_value = 1
    mock_dms_repository.get_user_name.return_value = "Mario"
    
    contact = TrustedContact(user_id="user1", contact_id="c1", contact_name="Luigi", contact_email="luigi@example.com", contact_phone_number="123")
    mock_contact_repository.list.return_value = [contact]
    
    service.update_dms_timers()
    
    mock_dms_repository.update_second_counter.assert_called_once_with("user1", 0)
    mock_notification_repository.send_email_message.assert_called_once()
    message = mock_notification_repository.send_email_message.call_args[0][0]
    assert message.destination_contact_email == "luigi@example.com"
    assert "Mario non accede alla nostra applicazione" in message.body
