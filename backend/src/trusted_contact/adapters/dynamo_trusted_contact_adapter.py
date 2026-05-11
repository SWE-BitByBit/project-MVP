import os
from typing import List, Optional
import boto3
from botocore.exceptions import ClientError
from boto3.dynamodb.conditions import Key

from domain.trusted_contact import TrustedContact
from ports.trusted_contact_repository_port import TrustedContactRepositoryPort

class DynamoTrustedContactAdapter(TrustedContactRepositoryPort):
    def __init__(self, dynamodb=None):
        self._dynamodb_client = dynamodb or boto3.resource(
            "dynamodb",
            region_name=os.environ["REGION"]
        )
        self._table = self._dynamodb_client.Table(os.environ["TRUSTED_CONTACT_TABLE"])

    def add(self, contact: TrustedContact) -> Optional[TrustedContact]:
        
        try:
            self._table.put_item(
                Item = {
                    "user_id": contact.user_id,
                    "contact_id": contact.contact_id,
                    "contact_name": contact.contact_name,
                    "contact_email": contact.contact_email,
                    "contact_phone_number": contact.contact_phone_number
                } 
            )
        except ClientError as e:
            raise RuntimeError(f"Error in adding the trusted contact: {e.response['Error']['Message']}")
        
        return contact
    
    def get(self, user_id: str, contact_id: str) -> Optional[TrustedContact]:

        try:
            response = self._table.get_item(
                Key={
                    "user_id": user_id,
                    "contact_id": contact_id
                }
            )
            item = response.get("Item")
            if not item or item.get("user_id") != user_id:
                return None
            
            return TrustedContact(
                user_id = item.get("user_id"),
                contact_id = item.get("contact_id"),
                contact_name = item.get("contact_name"),
                contact_email = item.get("contact_email"),
                contact_phone_number = item.get("contact_phone_number")
            )
        except ClientError as e:
            raise RuntimeError(f"Error in fetching trusted contact: {e.response['Error']['Message']}")
        
    def delete(self, user_id: str, contact_id: str) -> None:

        try:
            existing = self.get(user_id, contact_id)
            if not existing:
                raise KeyError(f"Contact {contact_id} not found")
            
            self._table.delete_item(
                Key={"user_id": user_id, "contact_id": contact_id}
            )
        
        except KeyError:
            raise
        except ClientError as e:
            raise RuntimeError(f"Error in deleting trusted contact: {e.response['Error']['Message']}")

    def update(self, contact: TrustedContact) -> Optional[TrustedContact]:
        try:
            existing = self.get(contact.user_id, contact.contact_id)
            if not existing:
                raise KeyError(f"Contact {contact.contact_id} not found")
            
            self._table.update_item(
                Key={
                    "user_id": contact.user_id,
                    "contact_id": contact.contact_id
                },
                UpdateExpression="SET contact_name = :name, contact_email = :email, contact_phone_number = :phone",
                ExpressionAttributeValues={
                    ':name': contact.contact_name,
                    ':email': contact.contact_email,
                    ':phone': contact.contact_phone_number,
                }
            )
            return contact
        except KeyError:
            raise
        except ClientError as e:
            raise RuntimeError(f"Error in updating trusted contact: {e.response['Error']['Message']}")


    def list(self, user_id: str) -> Optional[List[TrustedContact]]:
        
        try:    
            response = self._table.query(
                KeyConditionExpression = Key("user_id").eq(user_id)
            )
            trusted_contacts: List[TrustedContact] = []

            for item in response.get("Items", []):
                trusted_contacts.append(
                    TrustedContact(
                        user_id = item.get("user_id"),
                        contact_id = item.get("contact_id"),
                        contact_name = item.get("contact_name"),
                        contact_email = item.get("contact_email"),
                        contact_phone_number = item.get("contact_phone_number")
                    )
                )
            
            return trusted_contacts
        except ClientError as e:
            raise RuntimeError(f"Error in updating trusted contact: {e.response['Error']['Message']}")



