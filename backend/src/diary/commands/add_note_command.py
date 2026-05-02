from datetime import datetime
from typing import List

from commands.add_element_new_note_command import AddElementNewNoteCmd


class AddNoteCmd:
    def __init__(
        self,
        user_id: str,
        title: str,
        created_at: datetime,
        last_modified_at: datetime,
        diary_type,
        note_elements: List[AddElementNewNoteCmd]
    ):
        self.user_id = user_id
        self.title = title
        self.created_at = created_at
        self.last_modified_at = last_modified_at
        self.diary_type = diary_type
        self.note_elements = note_elements or []