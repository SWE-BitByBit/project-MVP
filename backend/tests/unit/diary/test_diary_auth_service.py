import pytest
from unittest.mock import MagicMock
from src.diary.services.diary_auth_service import DiaryAuthService
from src.diary.commands.set_password_command import SetPasswordCmd
from domain.diary_type import DiaryType

@pytest.fixture
def mock_repo():
    return MagicMock()

@pytest.fixture
def service(mock_repo):
    return DiaryAuthService(mock_repo)

def test_password_validation_logic(service):
    # Test regole di complessità
    assert service.is_valid_password("Valida1234!") is True
    assert service.is_valid_password("corta") is False # < 10
    assert service.is_valid_password("SoloLettere!") is False # No numeri
    assert service.is_valid_password("solopiccolo1!") is False # No maiuscole
    assert service.is_valid_password("SOLOMAIUSCOLO1!") is False # No minuscole
    assert service.is_valid_password("SenzaSpeciali1") is False # No speciali
    assert service.is_valid_password("Con Spazio1!") is False # No spazi

def test_set_real_password_first_time(service, mock_repo):
    # Mock status: prima volta, nessuna password reale impostata
    service.check_password_status = MagicMock(return_value={"has_real_password": False})
    mock_repo.set_password.return_value = True
    
    cmd = SetPasswordCmd(
        user_id="user1",
        password="NuovaPassword123!",
        diary_type=DiaryType.REAL_DIARY,
        previous_password=""
    )
    
    service.set_real_password(cmd)
    
    mock_repo.set_password.assert_called_with(
        password="NuovaPassword123!",
        user_id="user1",
        diary_type=DiaryType.REAL_DIARY
    )

def test_set_real_password_invalid_complexity(service):
    cmd = SetPasswordCmd(
        user_id="user1",
        password="weak",
        diary_type=DiaryType.REAL_DIARY,
        previous_password=""
    )
    
    with pytest.raises(ValueError, match="Password does not meet safety requirements"):
        service.set_real_password(cmd)

def test_check_password_status_mapping(service, mock_repo):
    # Caso utente con entrambe le password
    mock_repo.get_user_passwords.return_value = {
        "real_password": "hash1",
        "fake_password": "hash2"
    }
    
    status = service.check_password_status("user1")
    assert status["has_real_password"] is True
    assert status["has_fake_password"] is True

    # Caso utente senza password
    mock_repo.get_user_passwords.return_value = None
    status = service.check_password_status("user2")
    assert status["has_real_password"] is False
    assert status["has_fake_password"] is False
