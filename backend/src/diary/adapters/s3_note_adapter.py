import os
import boto3
from botocore.exceptions import ClientError

class S3NoteAdapter:

    def __init__(self, s3_client):
        self.s3_client = s3_client

    def generate_presigned_url(self, client_method, params, expires_in = 3600):
        """
            Create un presigned_url che sia per l'upload o il download in base al parametro passato
        """
        try:
            return self.s3_client.generate_presigned_url(
                ClientMethod=client_method,
                Params=params,
                ExpiresIn=expires_in
            )
        except ClientError:
            print("Couldn't get a presigned URL.")
            raise

    def delete_object(self, key):
        """Cancella un elemento dal bucket che corrisponde alla chiave data"""
        try:
            self.s3_client.delete_object(
                Bucket=os.environ["S3_BUCKET_NOTES_NAME"],
                Key=key
            )
        except ClientError as e:
            print("Error deleting S3 object:", e)
            raise