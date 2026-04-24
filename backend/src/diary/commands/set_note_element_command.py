class SetNoteElementCmd:
    def __init__(
        self,
        user_id: str,
        note_id: str,
        type: str,
        content: str
    ):
        self.user_id = user_id
        self.note_id = note_id
        self.type = type
        self.content = content