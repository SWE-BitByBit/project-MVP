from ulid import ULID
import os
from typing import List

from domain.note import Note
from domain.note import NoteElement
from commands.add_note_command import AddNoteCmd
from commands.delete_note_element_command import DeleteNoteElementCmd
from commands.get_note_command import GetNoteCmd
from commands.get_notes_command import GetNotesCmd
from commands.set_note_element_command import SetNoteElementCmd
from commands.delete_note_command import DeleteNoteCmd

from ports.delete_note_port import DeleteNotePort
from ports.get_note_port import GetNotePort
from ports.set_note_port import SetNotePort
from ports.note_repository_port import NoteRepositoryPort
from ports.file_repository_port import FileRepositoryPort

class NoteService(GetNotePort, SetNotePort, DeleteNotePort):

    def __init__(self, note_repository: NoteRepositoryPort, file_repository: FileRepositoryPort):
        self.note_repository = note_repository
        self.file_repository = file_repository

    def add_note(self, cmd: AddNoteCmd) -> Note:

        note = Note(
            note_id=str(ULID()),
            user_id=cmd.user_id,
            title=cmd.title,
            created_at=cmd.created_at,
            last_modified_at=cmd.last_modified_at,
            message_elements=[],
            diary_type=cmd.diary_type
        )

        presigned_urls = []

        for element in cmd.elements:

            element.note_id = note.note_id

            if element.type in ["image", "audio"]:
                key = f"{cmd.user_id}/{note.note_id}/{element.note_element_id}"

                presigned_url = self.file_repository.generate_presigned_url(
                    "put_object",
                    {
                        "Bucket": os.environ["BUCKET_NAME"],
                        "Key": key,
                    },
                    300
                )

                element.content = key

                presigned_urls.append({
                    "element_id": element.note_element_id,
                    "upload_url": presigned_url
                })

            note.message_elements.append(element)

        self.note_repository.add(note)

        return {
            "note_id": note.note_id,
            "upload_urls": presigned_urls
        }

    def get_note(self, cmd: GetNoteCmd) -> Note:
        item = self.note_repository.get(
            cmd.user_id,
            cmd.note_id,
            cmd.diary_type
        )

        elements = []

        for element in item.get("message_elements", []):

            if element["type"] in ["image", "audio"]:
                content = self.file_repository.generate_presigned_url(
                    "get_object",
                    {
                        "Bucket": os.environ["BUCKET_NAME"],
                        "Key": element["content"],
                    },
                    500
                )
            else:
                content = element["content"]

            elements.append({
                "element_id": element["element_id"],
                "type": element["type"],
                "content": content,
                "created_at": element.get("created_at")
            })

        return {
            "note_id": item["note_id"],
            "user_id": item["user_id"],
            "title": item["title"],
            "created_at": item["created_at"],
            "last_modified_at": item["last_modified_at"],
            "diary_type": item["diary_type"],
            "elements": elements
        }


    def delete_note(self, cmd: DeleteNoteCmd) -> bool:
        #TODO
        return True

    def list_notes(self, cmd: GetNotesCmd) -> List[Note]:
        return self.note_repository.list(
            cmd.user_id,
            cmd.diary_type
        )

    def add_note_element(self, cmd: SetNoteElementCmd):

        element_id = str(ULID())

        element = NoteElement(
            note_element_id=element_id,
            user_id=cmd.user_id,
            note_id=cmd.note_id,
            type=cmd.type,
            content=None
        )

        response = {
            "element_id": element_id
        }

        if cmd.type in ["image", "audio"]:
            key = f"{cmd.user_id}/{cmd.note_id}/{element_id}"

            presigned_url = self.file_repository.generate_presigned_url(
                "put_object",
                {
                    "Bucket": os.environ["BUCKET_NAME"],
                    "Key": key,
                },
                300
            )

            element.content = key

            response["upload_url"] = presigned_url

        else:
            element.content = cmd.content

        self.note_repository.add_note_element(
            cmd.user_id,
            cmd.note_id,
            element
        )

        return response
        
    
def delete_note_element(self, cmd: DeleteNoteElementCmd):

    note = self.note_repository.get(
        cmd.user_id,
        cmd.note_id,
        cmd.diary_type  
    )

    elements = note.get("message_elements", [])

    element = next(
        (el for el in elements if el["element_id"] == cmd.note_element_id),
        None
    )

    if not element:
        return {"error": "Element not found"}

    if element["type"] in ["image", "audio"]:
        self.file_repository.delete_object(
            key=element["content"]
        )

    self.note_repository.delete_note_element(
        cmd.user_id,
        cmd.note_id,
        cmd.note_element_id
    )




        