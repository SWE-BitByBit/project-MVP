from dataclasses import dataclass
from datetime import datetime
from typing import List

from diary_type import DiaryType
from note_element import NoteElement

@dataclass
class NoteDTO:
    note_id: str
    user_id: str
    title: str
    created_at: datetime
    last_modified_at: datetime
    diary_type: DiaryType

    def to_dict(self):
        return {
            "note_id": self.note_id,
            "user_id": self.user_id,
            "title": self.title,
            "created_at": self.created_at.isoformat() if hasattr(self.created_at, "isoformat") else self.created_at,
            "last_modified_at": self.last_modified_at.isoformat() if hasattr(self.last_modified_at, "isoformat") else self.last_modified_at,
            "diary_type": self.diary_type,
        }

    @staticmethod
    def from_domain(note):
        return NoteDTO(
            note_id=note.note_id,
            user_id=note.user_id,
            title=note.title,
            created_at=note.created_at,
            last_modified_at=note.last_modified_at,
            diary_type=note.diary_type,
        )