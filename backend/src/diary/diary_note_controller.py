import json
from ulid import ULID

from commands.add_note_command import AddNoteCmd
from commands.get_note_command import GetNoteCmd
from commands.get_notes_command import GetNotesCmd
from commands.add_note_element_command import AddNoteElementCmd
from commands.delete_note_element_command import DeleteNoteElementCmd
from domain.diary_type import DiaryType
from domain.dtos.note_dto import NoteDTO

SERVER_ERROR = {"message": "Internal server error"}

class DiaryNoteController:

    def __init__(self, service):
        self._service = service

    def response(self, status, body):
        return {
            "statusCode": status,
            "body": json.dumps(body)
        }
    
    def _get_user_id(self, event):
        claims = (
            event.get("requestContext", {})
            .get("authorizer", {})
            .get("jwt", {})
            .get("claims", {})
        )

        return claims.get("sub")

    def handle_request(self, event, context):
        route = event.get("routekey")

        if route == "PUT /note":
            return self._note_add(event)
        elif route == "GET /notes":
            return self._note_list(event)
        elif route == "GET /notes/{note_id}":
            return self._note_get(event)
        elif route == "DELETE /notes/{note_id}":
            return self._note_delete(event)
        elif route == "PUT note/element":
            return self._note_element_add(event)
        elif route == "DELETE note/element":
            return self._note_element_delete(event)

            
    def _note_add(self, event):
        body = json.loads(event.get("body") or "{}")

        try:
            diary_type = DiaryType(body.get("diary_type"))
        except ValueError:
            return self.response(400, {"message": "Invalid diary_type"})

        elements = [
            AddNoteElementCmd(
                user_id=self._get_user_id(event),
                type=element.get('type'),
                content=element.get('content')
            )
            for element in body.get('elements', [])
        ]

        response = self._service.add_note(
            AddNoteCmd(
                user_id=self._get_user_id(event),
                title=body.get('title'),
                created_at=body.get('created_at'),
                last_modified_at=body.get('last_modified_at'),
                diary_type=diary_type,
                elements=elements
            )
        )

        return self.response(201, response)
    

    def _note_get(self, event):
        body = json.loads(event.get("body") or "{}")

        try:
            diary_type = DiaryType(body.get("diary_type"))
            
            note = self._service.get_note(
                GetNoteCmd(
                    user_id=self._get_user_id(event),
                    note_id=body.get('note_id'),
                    diary_type=diary_type
                )
            )

            if not note:
                return self.response(404, {"message": "Note not found"})
            
            return self.response(200, note)

        except ValueError:
            return self.response(400, {"message": "Invalid diary_type"})
        
        except Exception:
            return self.response(500, SERVER_ERROR)


    def _note_list(self, event):
        body = json.loads(event.get("body") or "{}")

        try:
            diary_type = DiaryType(body.get("diary_type"))
        except ValueError:
            return self.response(400, {"message": "Invalid diary_type"})

        notes = self._service.list_notes(
            GetNotesCmd(
                user_id=self._get_user_id(event),
                diary_type=diary_type
            )
        )

        return self.response(200, {"notes": [NoteDTO.from_domain(n).to_dict() for n in notes]})


    def _note_delete(self, event):
        body = json.loads(event.get("body"))

        try:
            diary_type = DiaryType(body.get("diary_type"))
        except ValueError:
            return self.response(400, {"message": "Invalid diary_type"})

        
        result = self._service.delete_note(
            GetNoteCmd(
                user_id=self._get_user_id(event),
                note_id=body.get('note_id'),
                diary_type=diary_type
            )
        )
        if not result:
            return self.response(500, SERVER_ERROR)
        
        return self.response(200, {"message": "Note deleted successfully"})
        

    def _note_element_add(self, event):
        body = json.loads(event.get("body"))

        if not body.get("note_id") or not body.get("type"):
            return self.response(400, {"message": "Missing required fields"})

        try:
            response = self._service.add_note_element(
                AddNoteElementCmd(
                    self._get_user_id(event),
                    body.get("note_id"),
                    body.get("type"),
                    body.get("content")
                )
            )
        
            return self.response(200, response)
        
        except ValueError as e:
            return self.response(400, {"message": str(e)})

        except Exception:
            return self.response(500, SERVER_ERROR)


    def _note_element_delete(self, event):
        body = json.loads(event.get("body"))

        if not body.get("note_id") or not body.get("note_element_id"):
            return self.response(400, {"message": "Missing required fields"})

        result = self._service.delete_note_element(
            DeleteNoteElementCmd(
                self._get_user_id(event),
                body.get("note_id"),
                body.get("note_element_id"),
                body.get("type"),
                body.get("content")
            )
        )

        if not result:
            return self.response(500, SERVER_ERROR)

        return self.response(200, {"message": "Note element deleted successfully"})



