import os
import boto3
from botocore.exceptions import ClientError

from src.diary.domain.note import NoteElement
from src.diary.domain.note import Note

class DynamoNoteAdapter:

    def __init__(self):
        self.client = boto3.resource('dynamodb', region_name=os.environ["REGION"])
        self.table = self.client.Table(os.environ["TABLE_NOTES_NAME"])

    def add(self, note: Note):

        item = {
            "user_id": note.user_id,
            "note_id": note.note_id,
            "title": note.title,
            "created_at": note.created_at,
            "last_modified_at": note.last_modified_at,
            "diary_type": note.diary_type.value,
            "message_elements": [
                {
                    "element_id": el.note_element_id,
                    "type": el.type,
                    "content": el.content,
                }
                for el in note.message_elements
            ]
        }

        try:
            self.table.put_item(Item=item)
        except ClientError as e:
            print("Error adding the note:", e)
            raise
        
    def get(self, user_id, note_id, diary_type):
        try: 
            response = self.table.get_item(
                Key={
                    "user_id": user_id,
                    "note_id": note_id
                }
            )
        except ClientError as e:
            print("Error fetching the note:", e)
            raise

        item = response.get("Item")

        if not item:
            return None

        if item.get("diary_type") != diary_type.value:
            return None

        return item
    
    def list(self, user_id, diary_type):
        res = self.table.get

    def add_note_element(self, user_id, note_id, note_element: NoteElement):
        element_dict = {
            "element_id": note_element.note_element_id,
            "type": note_element.type,
            "content": note_element.content,
        }

        self.table.update_item(
            Key={
                "user_id": user_id,
                "note_id": note_id
            },
            UpdateExpression="SET message_elements = list_append(if_not_exists(message_elements, :empty), :el)",
            ExpressionAttributeValues={
                ":el": [element_dict],
                ":empty": []
            }
        )

    def delete_note_element(self, user_id, note_id, note_element_id):

        response = self.table.get_item(
            Key={
                "user_id": user_id,
                "note_id": note_id
            }
        )
        item = response.get("Item")
        elements = item.get("message_elements", [])
        filtered = [
            element for element in elements
            if element["element_id"] != note_element_id
        ]
        self.table.update_item(
            Key={
                "user_id": user_id,
                "note_id": note_id
            },
            UpdateExpression="SET message_elements = :els",
            ExpressionAttributeValues={
                ":els": filtered
            }
        )
    