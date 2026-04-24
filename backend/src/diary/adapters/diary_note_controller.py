import json
from ulid import ULID

from backend.src.diary.commands.add_note_command import AddNoteCmd
from commands.get_note_command import GetNoteCmd
from commands.get_notes_command import GetNotesCmd
from domain.note_element import NoteElement
from domain.diary_type import DiaryType

class DiaryNoteController:

    def __init__(self, service):
        self.service = service

    def response(self, status, body):
        return {
            "statusCode": status,
            "body": json.dumps(body)
        }
    
    def handle_response(self, event, context):
        route = event.get("routekey")

        if route == "PUT /note":
            return self.note_add(event)
        elif route == "GET /notes":
            return self.note_list(event)
        elif route == "GET /notes/{note_id}":
            return self.note_get(event)
        elif route == "DELETE /notes/{note_id}":
            return self.note_delete(event)

            
    def note_add(self, event):
        body = json.loads(event["body"])

        try:
            diary_type = DiaryType(body.get("diary_type"))
        except ValueError:
            return self.response(400, {"error": "Invalid diary_type"})

        elements = [
            NoteElement(
                note_element_id=str(ULID()),
                user_id=body.get('user_id'),
                note_id=None,
                type=element.get('type'),
                content=element.get('content')
            )
            for element in body.get('elements', [])
        ]

        note = self.service.add_note(
            AddNoteCmd(
                user_id=body.get('user_id'),
                title=body.get('title'),
                created_at=body.get('created_at'),
                last_modified_at=body.get('last_modified_at'),
                diary_type=diary_type,
                elements=elements
            )
        )

        return self.response(201, note)
    
    def note_get(self, event):
        body = json.loads(event["body"])

        try:
            diary_type = DiaryType(body.get("diary_type"))
        except ValueError:
            return self.response(400, {"error": "Invalid diary_type"})

        note = self.service.get_note(
            GetNoteCmd(
                user_id=body.get('user_id'),
                note_id=body.get('note_id'),
                diary_type=diary_type
            )
        )

        return self.response(200, note)

    def note_list(self, event):
        body = json.loads(event["body"])

        try:
            diary_type = DiaryType(body.get("diary_type"))
        except ValueError:
            return self.response(400, {"error": "Invalid diary_type"})

        notes = self.service.list_notes(
            GetNotesCmd(
                user_id=body.get('user_id'),
                diary_type=diary_type
            )
        )

        return self.response(200, notes)

    def note_delete(self, event):
        body = json.loads(event["body"])

        try:
            diary_type = DiaryType(body.get("diary_type"))
        except ValueError:
            return self.response(400, {"error": "Invalid diary_type"})

        try:
            self.service.get_note(
                GetNoteCmd(
                    user_id=body.get('user_id'),
                    note_id=body.get('note_id'),
                    diary_type=diary_type
                )
            )
        except ValueError:
            return self.response(400, {"error": ValueError})

