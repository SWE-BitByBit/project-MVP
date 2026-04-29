import boto3
import os

from adapters.dynamo_note_adapter import DynamoNoteAdapter
from adapters.dynamo_auth_adapter import DynamoAuthAdapter
from adapters.s3_note_adapter import S3NoteAdapter
from services.note_service import NoteService
from services.diary_auth_service import DiaryAuthService
from diary_access_controller import DiaryAccessController
from diary_note_controller import DiaryNoteController

def lambda_handler(event, context):
    route = event.get("routekey", "")

    if route.startswith("/diary/auth"):
        auth_adapter = DynamoAuthAdapter()
        auth_service = DiaryAuthService(auth_adapter)
        auth_controller = DiaryAccessController(auth_service)

        try:
            return auth_controller.handle_request(event, context)

        except Exception as e:
            return {
                "statusCode": 500,
                "body": {
                    "error": str(e)
                }
            }

    repo = DynamoNoteAdapter()
    storage = S3NoteAdapter(
        boto3.client("s3"),
        region_name=os.environ["REGION"]
    )

    service = NoteService(repo, storage)
    controller = DiaryNoteController(service)

    return controller.handle_response(event, context)