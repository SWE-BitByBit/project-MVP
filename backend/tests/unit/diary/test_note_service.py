import pytest
from unittest.mock import MagicMock, patch
from datetime import datetime

from services.note_service import NoteService
from commands.add_note_command import AddNoteCmd
from commands.delete_note_command import DeleteNoteCmd
from domain.diary_type import DiaryType
from domain.note import Note

@pytest.fixture
def mock_repos():
    return MagicMock(), MagicMock()

@pytest.fixture
def service(mock_repos):
    return NoteService(mock_repos[0], mock_repos[1])

def test_add_note_simple(service, mock_repos):
    mock_repo, _ = mock_repos
    cmd = AddNoteCmd(
        user_id="user1",
        title="Test Title",
        created_at=datetime.now(),
        last_modified_at=datetime.now(),
        diary_type=DiaryType.REAL_DIARY,
        note_elements=[]
    )
    
    mock_repo.get.return_value = None
    
    result = service.add_note(cmd, note_id=None)
    
    assert result["title"] == "Test Title"
    mock_repo.add.assert_called_once()
    added_note = mock_repo.add.call_args[0][0]
    assert added_note.title == "Test Title"

def test_add_note_already_exists(service, mock_repos):
    mock_repo, _ = mock_repos
    cmd = AddNoteCmd(
        user_id="user1",
        title="Existing",
        created_at=datetime.now(),
        last_modified_at=datetime.now(),
        diary_type=DiaryType.REAL_DIARY,
        note_elements=[]
    )
    
    existing_note = Note(
        note_id="note123",
        user_id="user1",
        title="Existing",
        created_at=datetime.now(),
        last_modified_at=datetime.now(),
        diary_type=DiaryType.REAL_DIARY,
        message_elements=[]
    )
    mock_repo.get.return_value = existing_note
    
    result = service.add_note(cmd, note_id="note123")
    
    # Dovrebbe restituire la nota esistente senza chiamare add
    assert result["note_id"] == "note123"
    mock_repo.add.assert_not_called()

def test_delete_note_calls_repos(service, mock_repos):
    mock_repo, mock_file_repo = mock_repos
    cmd = DeleteNoteCmd(
        user_id="user1",
        note_id="note123",
        diary_type=DiaryType.REAL_DIARY
    )
    
    mock_note = MagicMock(spec=Note)
    mock_note.message_elements = []
    mock_repo.get.return_value = mock_note
    
    success = service.delete_note(cmd)
    
    assert success is True
    mock_repo.delete.assert_called_with("user1", "note123", DiaryType.REAL_DIARY)

def test_delete_note_not_found(service, mock_repos):
    mock_repo, _ = mock_repos
    cmd = DeleteNoteCmd(
        user_id="user1",
        note_id="ghost",
        diary_type=DiaryType.REAL_DIARY
    )
    
    # Simula che la nota non esista o errore nel recupero
    mock_repo.get.side_effect = KeyError("Not found")
    
    success = service.delete_note(cmd)
    assert success is False
