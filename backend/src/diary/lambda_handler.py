import boto3
import os

from adapters.dynamo_note_adapter import DynamoNoteAdapter
from adapters.s3_note_adapter import S3NoteAdapter
from services.note_service import NoteService
from diary_note_controller import DiaryNoteController

def lambda_handler(event, context):

    repo = DynamoNoteAdapter()
    storage = S3NoteAdapter(boto3.client("s3"), region_name=os.environ["REGION"])

    service = NoteService(repo, storage)
    controller = DiaryNoteController(service)

    return controller.handle_response(event, context)