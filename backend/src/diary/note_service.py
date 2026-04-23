import uuid

from domain.note import Note
from ports.primary_ports import GetNotePort, SetNotePort, DeleteNotePort

class NoteService(GetNotePort, SetNotePort, DeleteNotePort):

    def __init__(self, note_repository, file_storage):
        self.note_repository = note_repository
        self.file_storage = file_storage

    def add_note(self, cmd):
        note = Note(
            note_id=str(uuid.uuid4()),
            user_id=cmd.user_id,
            title=cmd.title,
            created_at=cmd.created_at,
            last_modified_at=cmd.last_modified_at,
            message_elements=[],
            diary_type=cmd.diary_type
        )

        self.note_repository.add(note)
        return note

    def get_note(self, cmd):
        return self.note_repository.get(
            cmd.user_id,
            cmd.note_id,
            cmd.diary_type
        )

    def list_notes(self, cmd):
        return self.note_repository.list(
            cmd.user_id,
            cmd.diary_type
        )

    def add_note_element(self, user_id, note_id, file_name):
        key = f"{user_id}/{note_id}/{file_name}"
        return self.file_storage.generate_presigned_upload(key)