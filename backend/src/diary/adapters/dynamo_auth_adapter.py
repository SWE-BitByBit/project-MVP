import os
import hashlib
import hmac
import boto3
import secrets
from typing import Optional, Dict
from botocore.exceptions import ClientError
from ports.diary_auth_repository_port import DiaryAuthRepositoryPort
from domain.diary_type import DiaryType


class DynamoAuthAdapter(DiaryAuthRepositoryPort):
    
    def __init__(self):
        self.client = boto3.resource('dynamodb', region_name="eu-south-1")
        self.table = self.client.Table("auth_test")
        
        self.hash_secret = "38ae6a9f-1c7f-4df8-bfba-53e685ab3729"
    
    def hash_password(self, password: str, user_id: str) -> str:
        key = f"{self.hash_secret}:{user_id}".encode('utf-8')
        message = password.encode('utf-8')
        
        hash_obj = hmac.new(key, message, hashlib.sha256)
        return hash_obj.hexdigest()

    def start_session(self, user_id: str) -> str:
        try:
            access_token = secrets.token_urlsafe(32)

            self.table.update_item(
                Key={'user_id': user_id},
                UpdateExpression='SET access_token = :token',
                ExpressionAttributeValues={
                    ':token': access_token
                },
                ReturnValues='UPDATED_NEW'
            )

            return access_token

        except ClientError as e:
            print(f"DynamoDB error during session start: {e}")
            raise RuntimeError("Failed to start session")


    def end_session(self, user_id: str) -> None:
        try:
            self.table.update_item(
                Key={'user_id': user_id},
                UpdateExpression='REMOVE access_token'
            )

        except ClientError as e:
            print(f"DynamoDB error during session termination: {e}")
            raise RuntimeError("Failed to end session")
    
    def validate_password(self, password: str, user_id: str) -> Optional[DiaryType]:
        try:
            response = self.table.get_item(Key={'user_id': user_id})
            
            if 'Item' not in response:
                return None
            
            user_data = response['Item']
            password_hash = self.hash_password(password, user_id)
            print(password_hash)
            
            if user_data.get('real_password') == password_hash:
                return DiaryType.REAL_DIARY
            
            if user_data.get('fake_password') == password_hash:
                return DiaryType.FAKE_DIARY
            
            return None
            
        except ClientError as e:
            print(f"DynamoDB error during password validation: {e}")
            return None
    
    def validate_token(self, token: str, user_id: str) -> bool:
        try:
            response = self.table.get_item(Key={'user_id': user_id})
            
            if 'Item' not in response:
                return False
            
            user_data = response['Item']
            stored_token = user_data.get('access_token')
            if stored_token is None:
                return False

            return stored_token == token
            
        except ClientError as e:
            print(f"DynamoDB error during token validation: {e}")
            return False
    
    def set_password(
        self, 
        password: str, 
        user_id: str, 
        diary_type: DiaryType
    ) -> bool:
        try:
            password_hash = self.hash_password(password, user_id)
            user_data = self.get_user_passwords(user_id)

            if user_data:
                if diary_type == DiaryType.REAL_DIARY:
                    if user_data.get("fake_password") == password_hash:
                        raise ValueError("Real password cannot be the same as fake password")
                else:
                    if user_data.get("real_password") == password_hash:
                        raise ValueError("Fake password cannot be the same as real password")

            attribute_name = (
                'real_password' if diary_type == DiaryType.REAL_DIARY 
                else 'fake_password'
            )
            
            self.table.update_item(
                Key={'user_id': user_id},
                UpdateExpression=f'SET {attribute_name} = :password',
                ExpressionAttributeValues={':password': password_hash},
                ReturnValues='UPDATED_NEW'
            )
            
            return True
            
        except ClientError as e:
            print(f"DynamoDB error during password setting: {e}")
            return False
    
    def get_user_passwords(self, user_id: str) -> Optional[Dict[str, Optional[str]]]:
        try:
            response = self.table.get_item(Key={'user_id': user_id})
            
            if 'Item' not in response:
                return None
            
            user_data = response['Item']
            return {
                'real_password': user_data.get('real_password'),
                'fake_password': user_data.get('fake_password')
            }
            
        except ClientError as e:
            print(f"DynamoDB error during password retrieval: {e}")
            return None