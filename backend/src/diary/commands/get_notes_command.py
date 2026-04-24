class GetNotesCmd:
    def __init__(self, user_id: str, diary_type):
        self.user_id = user_id
        self.diary_type = diary_type