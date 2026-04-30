from domain.diary_type import DiaryType

class DeleteNoteElementCmd:
    def __init__(
        self,
        user_id: str,
        note_id: str,
        note_element_id: str,
        type: str,
        content: str
    ):
        self.user_id = user_id
        self.note_id = note_id
        self.note_element_id = note_element_id
        self.type = type
        self.content = content
