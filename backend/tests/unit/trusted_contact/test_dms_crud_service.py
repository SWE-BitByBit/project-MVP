import pytest
from unittest.mock import MagicMock

from src.trusted_contact.services.dms_crud_service import DmsCRUDService
from src.trusted_contact.domain.dms_configuration_settings import DmsConfigurationSettings

@pytest.fixture
def mock_repository():
    return MagicMock()

@pytest.fixture
def service(mock_repository):
    return DmsCRUDService(repository=mock_repository)

@pytest.fixture
def sample_config():
    return DmsConfigurationSettings(
        user_id="user1",
        is_active=True,
        first_timer=60,
        second_timer=120,
        email_subject="Emergency",
        email_body="Help"
    )

def test_send_heartbeat_active(service, mock_repository, sample_config):
    mock_repository.get_dms_config.return_value = sample_config
    
    service.send_heartbeat("user1")
    
    mock_repository.get_dms_config.assert_called_once_with("user1")
    mock_repository.update_first_counter.assert_called_once_with("user1", 60)
    mock_repository.update_second_counter.assert_called_once_with("user1", 120)

def test_send_heartbeat_inactive(service, mock_repository, sample_config):
    sample_config.is_active = False
    mock_repository.get_dms_config.return_value = sample_config
    
    service.send_heartbeat("user1")
    
    mock_repository.get_dms_config.assert_called_once_with("user1")
    mock_repository.update_first_counter.assert_not_called()
    mock_repository.update_second_counter.assert_not_called()

def test_get_dms_config(service, mock_repository, sample_config):
    mock_repository.get_dms_config.return_value = sample_config
    
    result = service.get_dms_config("user1")
    
    assert result == sample_config
    mock_repository.get_dms_config.assert_called_once_with("user1")

def test_update_dms_configuration_settings(service, mock_repository, sample_config):
    mock_repository.get_dms_config.return_value = sample_config
    
    service.update_dms_configuration_settings(sample_config)
    
    mock_repository.update_dms_config.assert_called_once_with(sample_config)
    # verify heartbeat was sent (since it calls send_heartbeat internally)
    mock_repository.get_dms_config.assert_called_once_with("user1")
    mock_repository.update_first_counter.assert_called_once_with("user1", 60)
    mock_repository.update_second_counter.assert_called_once_with("user1", 120)

def test_create_dms_configuration_settings(service, mock_repository, sample_config):
    mock_repository.add_dms_config.return_value = sample_config
    
    result = service.create_dms_configuration_settings("user1", "user1@example.com", "Mario")
    
    assert result == sample_config
    mock_repository.add_dms_config.assert_called_once_with("user1", "user1@example.com", "Mario")
