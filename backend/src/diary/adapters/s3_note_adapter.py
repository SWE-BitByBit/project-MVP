import boto3

class S3NoteAdapter:

    def __init__(self, bucket):
        self.client = boto3.client('s3')
        self.bucket = bucket

    def generate_presigned_upload(self, key):
        return self.client.generate_presigned_url(
            'put_object',
            Params={
                'Bucket': self.bucket,
                'Key': key
            },
            ExpiresIn=300
        )