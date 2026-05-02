import os
import boto3
from botocore.exceptions import ClientError

from ports.notification_port import NotificationPort
from domain.email_message import EmailMessage

class SesNotificationAdapter(NotificationPort):

    def __init__(self, ses_client=None):
        self._ses_client = ses_client or boto3.client(
            "ses",
            region_name=os.environ["REGION"]
        )

    def send_email_message(self, message: EmailMessage) -> str:
        try:
            response = self._ses_client.send_email(
                Source=message.source_email,
                Destination={"ToAddresses": [message.destination_contact_email]},
                Message={
                    "Subject": {"Data": message.subject},
                    "Body": {"Html": {"Data": message.body}}
                }
            )
            return response["MessageId"]
        except ClientError as e:
            raise RuntimeError(f"Error sending email: {e.response['Error']['Message']}")