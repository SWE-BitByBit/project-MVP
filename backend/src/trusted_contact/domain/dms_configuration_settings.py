class DmsConfigurationSettings:
    def __init__(
        self,
        user_id,
        is_active,
        first_timer,
        second_timer,
        email_subject,
        email_body,   
    ):
        self.user_id = user_id
        self.is_active = is_active
        self.first_timer = first_timer
        self.second_timer = second_timer
        self.email_subject = email_subject
        self.email_body = email_body