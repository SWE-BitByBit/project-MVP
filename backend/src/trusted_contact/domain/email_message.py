class EmailMessage():
    def __init__(
        self,
        source_email,
        destination_contact_email,
        contact_name,
        subject,
        body,
    ):
        self.source_email = source_email
        self.destination_contact_email = destination_contact_email
        self.contact_name = contact_name
        self.subject = subject
        self.body = body
