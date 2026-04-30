import os
import hashlib
import hmac
import boto3
from typing import Optional, Dict
from botocore.exceptions import ClientError
from ports.diary_auth_repository_port import DiaryAuthRepositoryPort
from domain.diary_type import DiaryType


class DynamoAuthAdapter(DiaryAuthRepositoryPort):
    
    def __init__(self):
        self.client = boto3.resource('dynamodb', region_name=os.environ["REGION"])
        self.table = self.client.Table(os.environ["TABLE_AUTH_NAME"])
        self.hash_secret = os.environ["HASH_SECRET"]
    
    def hash_password(self, password: str, user_id: str) -> str:
        key = f"{self.hash_secret}:{user_id}".encode('utf-8')
        message = password.encode('utf-8')
        
        hash_obj = hmac.new(key, message, hashlib.sha256)
        return hash_obj.hexdigest()
    
    def validate_password(self, password: str, user_id: str) -> str:
        try:
            response = self.table.get_item(Key={'user_id': user_id})
            
            if 'Item' not in response:
                return "invalid"
            
            user_data = response['Item']
            password_hash = self.hash_password(password, user_id)
            print(password_hash)
            
            if user_data.get('real_password') == password_hash:
                return "real"
            
            if user_data.get('fake_password') == password_hash:
                return "fake"
            
            return "invalid"
            
        except ClientError as e:
            print(f"DynamoDB error during password validation: {e}")
            return "invalid"
    
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