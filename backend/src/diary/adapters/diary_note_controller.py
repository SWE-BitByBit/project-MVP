import json

class DiaryNoteController:

    def __init__(self, service):
        self.service = service

    def response(self, status, body):
        return {
            "statusCode": status,
            "body": json.dumps(body)
        }
    
    def handle_response(self, event, context):
        route = event.get("routekey")

        if route == "PUT /note":
            self.service.create_note(event)
        if route == "GET /notes":
            

    def create_note(self, event):
        body = json.loads(event["body"])

        note = self.service.add_note(body)

        presigned = self.service.add_note_element(
            body["user_id"],
            note.note_id,
            body["fileName"]
        )

        return self.response(201, {
            "note_id": note.note_id,
            "presigned_url": presigned
        })