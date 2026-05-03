class EmailMessage():
    def __init__(
        self,
        source_email,
        destination_contact_email,
        subject,
        body,
    ):
        self.source_email = source_email
        self.destination_contact_email = destination_contact_email
        self.subject = subject
        self.body = body
