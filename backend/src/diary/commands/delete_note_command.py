class DeleteNoteCmd:
    def __init__(self, user_id: str, note_id: str, diary_type):
        self.user_id = user_id
        self.note_id = note_id
        self.diary_type = diary_type