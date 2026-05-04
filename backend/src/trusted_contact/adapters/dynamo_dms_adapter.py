import os
from typing import List
import boto3
from botocore.exceptions import ClientError

from domain.dms_configuration_settings import DmsConfigurationSettings
from ports.dms_repository_port import DmsRepositoryPort

class DynamoDmsAdapter(DmsRepositoryPort):

    def __init__(self, dynamodb=None):
        self._dynamodb_client = dynamodb or boto3.resource(
            "dynamodb",
            region_name=os.environ["REGION"]
        )
        self._table = self._dynamodb_client.Table(os.environ["DMS_TABLE"])

    def add_dms_config(self, user_id: str, user_email: str, user_name: str) -> DmsConfigurationSettings:

        config = DmsConfigurationSettings(
            user_id=user_id,
            is_active=False,
            first_timer=0,
            second_timer=0,
            email_subject="",
            email_body=""
        )

        try:
            self._table.put_item(
                Item={
                    "user_id": user_id,
                    "user_email": user_email,
                    "user_name": user_name,
                    "is_active": config.is_active,
                    "first_timer": config.first_timer,
                    "second_timer": config.second_timer,
                    "email_subject": config.email_subject,
                    "email_body": config.email_body,
                    "first_timer_count_down": 0,
                    "second_timer_count_down": 0,
                },
                ConditionExpression="attribute_not_exists(user_id)"
            )
            return config

        except ClientError as e:
            if e.response['Error']['Code'] == 'ConditionalCheckFailedException':
                return config
            else:
                raise RuntimeError(f"Error adding DMS config: {e.response['Error']['Message']}")

    def get_dms_config(self, user_id: str) -> DmsConfigurationSettings:

        try:
            response = self._table.get_item(
                Key={"user_id": user_id},
                ConsistentRead=True
            )
            item = response.get("Item")
            if not item:
                raise KeyError(f"DMS config not found for user {user_id}")
            
            return DmsConfigurationSettings(
                user_id=item["user_id"],
                is_active=item["is_active"],
                first_timer=int(item["first_timer"]),
                second_timer=int(item["second_timer"]),
                email_subject=item["email_subject"],
                email_body=item["email_body"]
            )
        except ClientError as e:
            raise RuntimeError(f"Error fetching DMS config: {e.response['Error']['Message']}")

    def update_dms_config(self, config: DmsConfigurationSettings) -> None:

        try:
            existing = self.get_dms_config(config.user_id)

            if not existing:
                raise KeyError(f"DMS config not found for user {config.user_id}")
            
            self._table.update_item(
                Key={"user_id": config.user_id},
                UpdateExpression="""
                    SET is_active = :active,
                        first_timer = :first,
                        second_timer = :second,
                        email_subject = :subject,
                        email_body = :body
                """,
                ExpressionAttributeValues={
                    ":active": config.is_active,
                    ":first": config.first_timer,
                    ":second": config.second_timer,
                    ":subject": config.email_subject,
                    ":body": config.email_body,
                }
            )

        except KeyError:
            raise
        except ClientError as e:
            raise RuntimeError(f"Error updating DMS config: {e.response['Error']['Message']}")

    def get_first_timer(self, user_id: str) -> int:

        try:
            response = self._table.get_item(
                Key={"user_id": user_id}
            )
            item = response.get("Item")

            if not item:
                raise KeyError(f"DMS config not found for user {user_id}")
            return int(item["first_timer_count_down"])
        
        except ClientError as e:
            raise RuntimeError(f"Error fetching first timer: {e.response['Error']['Message']}")

    def get_second_timer(self, user_id: str) -> int:

        try:
            response = self._table.get_item(
                Key={"user_id": user_id}
            )
            item = response.get("Item")
            if not item:
                raise KeyError(f"DMS config not found for user {user_id}")
            return int(item["second_timer_count_down"])
        
        except ClientError as e:
            raise RuntimeError(f"Error fetching second timer: {e.response['Error']['Message']}")

    def update_first_counter(self, user_id: str, remaining_days: int) -> None:

        try:
            self._table.update_item(
                Key={"user_id": user_id},
                UpdateExpression="SET first_timer_count_down = :val",
                ExpressionAttributeValues={":val": remaining_days}
            )

        except ClientError as e:
            raise RuntimeError(f"Error updating first counter: {e.response['Error']['Message']}")

    def update_second_counter(self, user_id: str, remaining_days: int) -> None:

        try:
            self._table.update_item(
                Key={"user_id": user_id},
                UpdateExpression="SET second_timer_count_down = :val",
                ExpressionAttributeValues={":val": remaining_days}
            )

        except ClientError as e:
            raise RuntimeError(f"Error updating second counter: {e.response['Error']['Message']}")
        
    def list_all_configs(self) -> List[DmsConfigurationSettings]:

        try:
            response = self._table.scan()
            configs: List[DmsConfigurationSettings] = []

            for item in response.get("Items", []):
                configs.append(
                    DmsConfigurationSettings(
                        user_id=item["user_id"],
                        is_active=item["is_active"],
                        first_timer=item["first_timer"],
                        second_timer=item["second_timer"],
                        email_subject=item["email_subject"],
                        email_body=item["email_body"]
                    )
                )
            
            return configs
        except ClientError as e:
            raise RuntimeError(f"Error scanning DMS configs: {e.response['Error']['Message']}")
        

    def get_user_email(self, user_id: str) -> str:
        try:
            response = self._table.get_item(
                Key={"user_id": user_id}
            )
            item = response.get("Item")
            if not item:
                raise KeyError(f"DMS config not found for user {user_id}")
            return item["user_email"]
    
        except ClientError as e:
            raise RuntimeError(f"Error fetching user email: {e.response['Error']['Message']}")
        
    
    def get_user_name(self, user_id: str) -> str:
        try:
            response = self._table.get_item(
                Key={"user_id": user_id}
            )
            item = response.get("Item")
            if not item:
                raise KeyError(f"DMS config not found for user {user_id}")
            return item["user_name"]
    
        except ClientError as e:
            raise RuntimeError(f"Error fetching user name: {e.response['Error']['Message']}")