from datetime import datetime
from typing import List
from .note_element import NoteElement
from .diary_type import DiaryType

class Note:
    def __init__(
        self,
        note_id: str,
        user_id: str,
        title: str,
        created_at: datetime,
        last_modified_at: datetime,
        message_elements: List[NoteElement],
        diary_type: DiaryType
    ):
        self.note_id = note_id
        self.user_id = user_id
        self.title = title
        self.created_at = created_at
        self.last_modified_at = last_modified_at
        self.message_elements = message_elements
        self.diary_type = diary_type