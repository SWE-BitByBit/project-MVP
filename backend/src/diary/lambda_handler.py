from adapters.dynamo_note_adapter import DynamoNoteAdapter
from adapters.s3_note_adapter import S3NoteAdapter
from note_service import NoteService
from adapters.diary_note_controller import DiaryNoteController

def lambda_handler(event, context):

    # Dependency Injection
    repo = DynamoNoteAdapter("NotesTable")
    storage = S3NoteAdapter("notes-bucket")

    service = NoteService(repo, storage)
    controller = DiaryNoteController(service)

    path = event["path"]
    method = event["httpMethod"]

    if path == "/notes" and method == "PUT":
        return controller.create_note(event)

    return {
        "statusCode": 404,
        "body": "Not found"
    }