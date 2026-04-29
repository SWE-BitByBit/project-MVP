from .diary_type import DiaryType

class NoteElement:
    def __init__(
        self,
        note_id: str,
        note_element_id: str,
        type: str,
        content: str,
    ):
        self.note_id = note_id
        self.note_element_id = note_element_id
        self.type = type
        self.content = content