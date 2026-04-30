import os
import boto3
from botocore.exceptions import ClientError

class S3NoteAdapter:

    def __init__(self, s3_client=None):
        self._s3_client = s3_client or boto3.client("s3")

    def generate_presigned_url(self, client_method, params, expires_in = 3600):
        """
            Create un presigned_url che sia per l'upload o il download in base al parametro passato
        """
        try:
            return self._s3_client.generate_presigned_url(
                ClientMethod=client_method,
                Params=params,
                ExpiresIn=expires_in
            )
        except ClientError:
            print("Couldn't get a presigned URL.")
            raise

    def delete_object(self, key: str) -> None:
        """
            Cancella un elemento dal bucket che corrisponde alla chiave data
        """
        try:
            self._s3_client.delete_object(
                Bucket=os.environ["S3_BUCKET_NOTES_NAME"],
                Key=key
            )
        except ClientError as e:
            raise RuntimeError(f"Error in deleting note element media: {e.response['Error']['Message']}")