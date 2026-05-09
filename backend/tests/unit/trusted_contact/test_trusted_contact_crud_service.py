import pytest
from unittest.mock import MagicMock, ANY

from src.trusted_contact.services.trusted_contact_crud_service import TrustedContactCRUDService
from src.trusted_contact.domain.trusted_contact import TrustedContact
from src.trusted_contact.commands.add_trusted_contact_command import AddTrustedContactCmd
from src.trusted_contact.commands.get_trusted_contact_command import GetTrustedContactCmd
from src.trusted_contact.commands.delete_trusted_contact_command import DeleteTrustedContactCmd

@pytest.fixture
def mock_repository():
    return MagicMock()

@pytest.fixture
def service(mock_repository):
    return TrustedContactCRUDService(repository=mock_repository)

@pytest.fixture
def sample_contact():
    return TrustedContact(
        user_id="user1",
        contact_id="c1",
        contact_name="Tywin",
        contact_email="tywin@gmail.com",
        contact_phone_number="111"
    )

def test_update_trusted_contact_success(service, mock_repository, sample_contact):
    mock_repository.list.return_value = []
    mock_repository.update.return_value = sample_contact
    
    result = service.update_trusted_contact(sample_contact)
    
    assert result == sample_contact
    mock_repository.update.assert_called_once_with(sample_contact)

def test_update_trusted_contact_email_exists(service, mock_repository, sample_contact):
    existing_contact = TrustedContact(
        user_id="user1",
        contact_id="c2",
        contact_name="Cersei",
        contact_email="tywin@gmail.com",
        contact_phone_number="222"
    )
    mock_repository.list.return_value = [existing_contact]
    
    with pytest.raises(ValueError, match="Email already exists"):
        service.update_trusted_contact(sample_contact)

def test_add_trusted_contact_success(service, mock_repository):
    mock_repository.list.return_value = []
    
    cmd = AddTrustedContactCmd(
        user_id="user1",
        contact_name="Jon",
        contact_email="jon@gmail.com",
        contact_phone_number="333"
    )
    
    expected_contact = TrustedContact(
        user_id="user1",
        contact_id="random-uuid",
        contact_name="Jon",
        contact_email="jon@gmail.com",
        contact_phone_number="333"
    )
    mock_repository.add.return_value = expected_contact
    
    result = service.add_trusted_contact(cmd)
    
    assert result == expected_contact
    mock_repository.add.assert_called_once_with(ANY)

def test_add_trusted_contact_email_exists(service, mock_repository, sample_contact):
    mock_repository.list.return_value = [sample_contact]
    
    cmd = AddTrustedContactCmd(
        user_id="user1",
        contact_name="Jon",
        contact_email="tywin@gmail.com",
        contact_phone_number="333"
    )
    
    with pytest.raises(ValueError, match="Email already exists"):
        service.add_trusted_contact(cmd)

def test_get_trusted_contact(service, mock_repository, sample_contact):
    mock_repository.get.return_value = sample_contact
    cmd = GetTrustedContactCmd(user_id="user1", contact_id="c1")
    
    result = service.get_trusted_contact(cmd)
    
    assert result == sample_contact
    mock_repository.get.assert_called_once_with("user1", "c1")

def test_get_all_trusted_contact(service, mock_repository, sample_contact):
    mock_repository.list.return_value = [sample_contact]
    
    result = service.get_all_trusted_contact("user1")
    
    assert result == [sample_contact]
    mock_repository.list.assert_called_once_with("user1")

def test_delete_trusted_contact_success(service, mock_repository):
    cmd = DeleteTrustedContactCmd(user_id="user1", contact_id="c1")
    
    result = service.delete_trusted_contact(cmd)
    
    assert result is True
    mock_repository.delete.assert_called_once_with("user1", "c1")

def test_delete_trusted_contact_not_found(service, mock_repository):
    mock_repository.delete.side_effect = KeyError("Not found")
    cmd = DeleteTrustedContactCmd(user_id="user1", contact_id="c1")
    
    result = service.delete_trusted_contact(cmd)
    
    assert result is False
