from ulid import ULID
import os
from typing import List
from botocore.exceptions import ClientError
from typing import Optional

from domain.note import Note
from domain.note import NoteElement
from commands.add_note_command import AddNoteCmd
from commands.delete_note_element_command import DeleteNoteElementCmd
from commands.get_note_command import GetNoteCmd
from commands.get_notes_command import GetNotesCmd
from commands.add_note_element_command import AddNoteElementCmd
from commands.delete_note_command import DeleteNoteCmd

from ports.delete_note_port import DeleteNotePort
from ports.get_note_port import GetNotePort
from ports.set_note_port import SetNotePort
from ports.set_note_element_port import SetNoteElementPort
from ports.note_repository_port import NoteRepositoryPort
from ports.file_repository_port import FileRepositoryPort

from domain.dtos.note_dto import NoteDTO
from domain.dtos.note_element_dto import NoteElementDTO

class NoteService(GetNotePort, SetNotePort, DeleteNotePort, SetNoteElementPort):

    def __init__(self, note_repository: NoteRepositoryPort, file_repository: FileRepositoryPort):
        self._note_repository = note_repository
        self._file_repository = file_repository

    def add_note(self, cmd: AddNoteCmd, note_id: str) -> dict:
        print(f"[DEBUG] add_note chiamato con note_id={note_id}, user_id={cmd.user_id}")
        if note_id:
            existing_note =  self._note_repository.get(
                cmd.user_id,
                note_id,
                cmd.diary_type
            )

            if existing_note:
                return self.get_note(
                    GetNoteCmd(
                        cmd.user_id,
                        note_id,
                        cmd.diary_type
                    )
                )

        note = Note(
            note_id=str(ULID()),
            user_id=cmd.user_id,
            title=cmd.title,
            created_at=cmd.created_at,
            last_modified_at=cmd.last_modified_at,
            diary_type=cmd.diary_type,
            message_elements=[]
        )
        print(f"[DEBUG] Nota creata: {note.note_id}")

        note_dict = NoteDTO.from_domain(note).to_dict()
        note_dict["note_elements"] = []

        for element in cmd.note_elements or []:
            print(f"[DEBUG] Elaboro elemento: type={element.type}, content={element.content}")
            note_element_id = str(ULID())

            if element.type in ["image", "audio"]:
                print(f"[DEBUG] Generazione presigned URL per {element.type}")
                key = f"{cmd.user_id}/{note.note_id}/{note_element_id}"

                note_element = NoteElement(
                    note_id=note.note_id,
                    note_element_id=note_element_id,
                    type=element.type,
                    content=key
                )
                note_element_dict = NoteElementDTO.from_domain(note_element).to_dict()

                try:
                    upload_url = self._file_repository.generate_presigned_url(
                        "put_object",
                        {
                            "Bucket": os.environ["S3_BUCKET_NOTES_NAME"], 
                            "Key": key
                        }
                    )
                    note_element_dict["upload_url"] = upload_url
                    print("[DEBUG] URL generato OK")
                except ClientError as e:
                    print(f"[DEBUG] ClientError: {e}")
                    raise RuntimeError("Error generating presigned URL for element") from e
                
            else:
                
                note_element = NoteElement(
                    note_id=note.note_id,
                    note_element_id=note_element_id,
                    type=element.type,
                    content=element.content
                )

                note_element_dict = NoteElementDTO.from_domain(note_element).to_dict()
            
            note.message_elements.append(note_element)
            note_dict["note_elements"].append(note_element_dict)

        print("[DEBUG] Salvataggio nota su DynamoDB")
        self._note_repository.add(note)
        print("[DEBUG] Nota salvata OK")
        return note_dict

    def get_note(self, cmd: GetNoteCmd) -> Optional[dict]:
        note = self._note_repository.get(
            cmd.user_id,
            cmd.note_id,
            cmd.diary_type
        )

        if not note:
            return None
        
        note_dict = NoteDTO.from_domain(note).to_dict()

        note_dict["note_elements"] = []

        for element in note.message_elements or []:

            note_element_dict = NoteElementDTO.from_domain(element).to_dict()

            if element.type in ["image", "audio"]:
                try:
                    download_url = self._file_repository.generate_presigned_url(
                        "get_object",
                        {
                            "Bucket": os.environ["BUCKET_NAME"],
                            "Key": element.content,
                        }
                    )
                    note_element_dict["download_url"] = download_url
                except ClientError as e:
                    raise RuntimeError(f"Error generating presigned URL for element {element.note_element_id}") from e
            
            note_dict["note_elements"].append(note_element_dict)

        return note_dict


    def delete_note(self, cmd: DeleteNoteCmd) -> bool:
        note: Note = self._note_repository.get(
            cmd.user_id,
            cmd.note_id,
            cmd.diary_type
        )

        for element in note.message_elements:
            if element.type in ["image", "audio"]:
                self._file_repository.delete_object(key=element.content)

        try:
            self._note_repository.delete(
                cmd.user_id,
                cmd.note_id,
                cmd.diary_type
            )
            return True
        except RuntimeError:
            return False
        except KeyError:
            return False

    def list_notes(self, cmd: GetNotesCmd) -> List[Note]:
        return self._note_repository.list(
            cmd.user_id,
            cmd.diary_type
        )

    def add_note_element(self, cmd: AddNoteElementCmd) -> dict:

        note_element: NoteElement = None

        note_element_id = str(ULID())

        if cmd.type in ["image", "audio"]:

            if cmd.content:
                raise ValueError("Content must be empty for file upload")

            key = f"{cmd.user_id}/{cmd.note_id}/{note_element_id}"
            note_element = NoteElement(
                note_id=cmd.note_id,
                note_element_id=note_element_id,
                type=cmd.type,
                content=key
            )
            note_element_dict = NoteElementDTO.from_domain(note_element).to_dict()

            try:
                upload_url = self._file_repository.generate_presigned_url(
                    "put_object",
                    {
                        "Bucket": os.environ["S3_BUCKET_NOTES_NAME"], 
                        "Key": key
                    }
                )
                note_element_dict["upload_url"] = upload_url

            except ClientError:
                raise RuntimeError("Error generating presigned URL")

        else:
            if not cmd.content:
                raise ValueError("Content is required for text type")
            
            note_element = NoteElement(
                note_id=cmd.note_id,
                note_element_id=note_element_id,
                type=cmd.type,
                content=cmd.content
            )
        
            note_element_dict = NoteElementDTO.from_domain(note_element).to_dict()

        self._note_repository.add_note_element(
            cmd.user_id,
            note_element
        )

        return note_element_dict
        
    
    def delete_note_element(self, cmd: DeleteNoteElementCmd) -> bool:

        try:
            note_element_to_delete = self._note_repository.get_note_element(
                cmd.user_id,
                cmd.note_id,
                cmd.note_element_id
            )
            self._note_repository.delete_note_element(
                cmd.user_id,
                cmd.note_id,
                cmd.note_element_id
            )
            
            if note_element_to_delete.type in ["image", "audio"]:
                self._file_repository.delete_object(
                    key=note_element_to_delete.content
                )
            
            return True
        
        except KeyError:
            return True
        
        except ValueError:
            return False
        
        except RuntimeError:
            return False       