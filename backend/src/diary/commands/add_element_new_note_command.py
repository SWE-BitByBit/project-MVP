class AddElementNewNoteCmd:
    def __init__(
        self,
        user_id: str,
        type: str,
        content: str
    ):
        self.user_id = user_id
        self.type = type
        self.content = content