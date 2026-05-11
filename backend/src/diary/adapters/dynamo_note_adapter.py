import os
import boto3
from typing import List, Optional
from botocore.exceptions import ClientError
from boto3.dynamodb.conditions import Key, Attr

from domain.note_element import NoteElement
from domain.note import Note
from domain.diary_type import DiaryType

from ports.note_repository_port import NoteRepositoryPort

class DynamoNoteAdapter(NoteRepositoryPort):

    def __init__(self, dynamodb=None):
        self._dynamodb_client = dynamodb or boto3.resource(
            'dynamodb', 
            region_name=os.environ["REGION"])
        self._note_table = self._dynamodb_client.Table(os.environ["NOTES_TABLE"])
        self._note_elements_table = self._dynamodb_client.Table(os.environ["NOTES_ELEMENTS_TABLE"])


    def add(self, note: Note) -> Optional[Note]:

        try:
            self._note_table.put_item(
                Item = {
                    "user_id": note.user_id,
                    "note_id": note.note_id,
                    "title": note.title,
                    "created_at": note.created_at,
                    "last_modified_at": note.last_modified_at,
                    "diary_type": note.diary_type.value
                }
            )
            for note_element in note.message_elements:
                self.add_note_element(note.user_id, note_element)

            return note
        
        except ClientError as e:
            print("Error adding the note:", e)
            raise
    

    def get(self, user_id: str, note_id: str, diary_type: DiaryType) -> Optional[Note]:
        try: 
            note_response = self._note_table.get_item(
                Key={
                    "user_id": user_id,
                    "note_id": note_id
                }
            )

            note = note_response.get("Item")

            if not note:
                return None

            if note.get("diary_type") != diary_type.value:
                return None
            
            note_elements = self._get_note_elements(note_id)

            return Note(
                note_id=note["note_id"],
                user_id=note["user_id"],
                title=note["title"],
                created_at=note["created_at"],
                last_modified_at=note["last_modified_at"],
                diary_type=note["diary_type"],
                message_elements= note_elements
            )

        except ClientError as e:
            print(f"Error fetching the note: {e.response['Error']['Message']}")
            raise
    

    def list(self, user_id: str, diary_type: DiaryType) -> Optional[List[Note]]:
        try:
            notes_response = self._note_table.query(
                KeyConditionExpression=Key("user_id").eq(user_id),
                FilterExpression=Attr("diary_type").eq(diary_type.value)
            )

            notes: List[Note] = []
            for note in notes_response.get("Items", []):
                notes.append(
                    Note(
                        note_id=note["note_id"],
                        user_id=note["user_id"],
                        title=note["title"],
                        created_at=note["created_at"],
                        last_modified_at=note["last_modified_at"],
                        diary_type=DiaryType(note["diary_type"]),
                        message_elements=[]
                    )
                )
            return notes

        except ClientError as e:
            raise RuntimeError(f"Error listing notes: {e.response['Error']['Message']}")


    def delete(self, user_id: str, note_id: str, diary_type: DiaryType) -> None:
        try:
            existing = self.get(user_id, note_id, diary_type)
            if not existing:
                raise KeyError(f"Note {note_id} not found")

            elements = self._get_note_elements(note_id)
            for element in elements:
                self._note_elements_table.delete_item(
                    Key={"note_id": note_id, "note_element_id": element.note_element_id}
                )

            self._note_table.delete_item(
                Key={"user_id": user_id, "note_id": note_id}
            )

        except KeyError:
            raise
        except ClientError as e:
            raise RuntimeError(f"Error deleting note: {e.response['Error']['Message']}")


    def add_note_element(self, user_id: str, note_element: NoteElement) -> NoteElement:

        try:
            note_response = self._note_table.get_item(
                Key={"user_id": user_id, "note_id": note_element.note_id}
            )
            note_item = note_response.get("Item")
            if not note_item or note_item.get("user_id") != user_id:
                raise ValueError("Note not found or missing authorization")

            self._note_elements_table.put_item(
                Item={
                    "note_id": note_element.note_id,
                    "note_element_id": note_element.note_element_id,
                    "type": note_element.type,
                    "content": note_element.content,
                }
            )
            return note_element

        except (ValueError, KeyError):
            raise
        except ClientError as e:
            raise RuntimeError(f"Error adding note element: {e.response['Error']['Message']}")


    def delete_note_element(self, user_id: str, note_id: str, note_element_id: str) -> None:
        
        try:
            self.get_note_element(user_id, note_id, note_element_id)

            self._note_elements_table.delete_item(
                Key={"note_id": note_id, "note_element_id": note_element_id}
            )

        except (ValueError, KeyError):
            raise
        except ClientError as e:
            raise RuntimeError(f"Error deleting note element: {e.response['Error']['Message']}")
    

    def get_note_element(self, user_id: str, note_id: str, note_element_id: str) -> NoteElement:
        
        note_response = self._note_table.get_item(
            Key={"user_id": user_id, "note_id": note_id}
        )
        note_item = note_response.get("Item")
        if not note_item or note_item.get("user_id") != user_id:
            raise ValueError("Note not found or missing authorization")
        
        element_response = self._note_elements_table.get_item(
            Key={"note_id": note_id, "note_element_id": note_element_id}
        )
        item = element_response.get("Item")
        if not item:
            raise KeyError(f"Note element {note_element_id} not found")
        
        return NoteElement(   
            note_id=item["note_id"],
            note_element_id=item["note_element_id"],
            type=item["type"],
            content=item["content"],
        )


    def _get_note_elements(self, note_id: str) -> List[NoteElement]:

        response = self._note_elements_table.query(
            KeyConditionExpression=Key("note_id").eq(note_id),
            ScanIndexForward=True
        )
        elements: List[NoteElement] = []
        for item in response.get("Items", []):
            elements.append(
                NoteElement(
                    note_id=item["note_id"],
                    note_element_id=item["note_element_id"],
                    type=item["type"],
                    content=item["content"],
                )
            )
        return elements