from typing import List, Optional
from datetime import datetime, timezone

import boto3
from boto3.dynamodb.conditions import Key
from botocore.exceptions import ClientError
from ulid import ULID

from chats_repository_port import ChatsRepositoryPort
from chat import Chat
from chat_message import Message

class DynamoChatAdapter(ChatsRepositoryPort):
    def __init__(self):
        self._dynamodb = boto3.resource("dynamodb", region_name = "eu-south-1")
        self._chats_table = self._dynamodb.Table("chats_mvp")
        self._messages_table = self._dynamodb.Table("chats_messages_mvp")

    @staticmethod
    def _now_iso() -> str:
        return datetime.now(timezone.utc).isoformat()

    @staticmethod
    def _new_chat_id() -> str:
        return str(ULID())

    @staticmethod
    def _new_message_id() -> str:
        return str(ULID())

    def create_chat(self, user_id: str) -> Chat:
        chat_id = self._new_chat_id()
        created_at = self._now_iso()
        title = "Nuova chat"

        try:
            self._chats_table.put_item(
                Item = {
                    "title": title,
                    "chat_id": chat_id,
                    "user_id": user_id,
                    "created_at": created_at,
                    "updated_at": created_at,
                }
            )
        except ClientError as e:
            raise RuntimeError(f"Error in creating a new chat: {e.response['Error']['Message']}") 

        return Chat(
            title = title,
            chat_id = chat_id,
            user_id = user_id,
            created_at = created_at,
            updated_at = created_at,
            messages = []
        )

    def get_chat(self, user_id: str, chat_id: str) -> Optional[Chat]:

        try:
            chat_response = self._chats_table.get_item(
                Key = {"chat_id": chat_id},
                ConsistentRead = True
            )

            chat_item = chat_response.get("Item")
            if not chat_item or chat_item.get("user_id") != user_id:
                return None

            messages: List[Message] = []

            messages_response = self._messages_table.query(
                KeyConditionExpression = Key("chat_id").eq(chat_id),
                ScanIndexForward = True
            )

            for item in messages_response.get("Items", []):
                messages.append(
                    Message(
                        message_id = item["message_id"],
                        text = item.get("text"),
                        sender = item.get("sender"),
                        created_at = item.get("created_at")
                    )
                )

            return Chat(
                title = chat_item.get("title"),
                chat_id = chat_id,
                user_id = user_id,
                created_at = chat_item.get("created_at"),
                updated_at = chat_item.get("updated_at"),
                messages = messages
            )
        
        except ClientError as e:
            raise RuntimeError(f"Error in fetching the chat: {e.response['Error']['Message']}")

    def delete_chat(self, user_id: str, chat_id: str) -> bool:
        try:
            chat_response = self._chats_table.get_item(
                Key = {"chat_id": chat_id},
                ConsistentRead = True
            )

            chat_item = chat_response.get("Item")
            if not chat_item or chat_item.get("user_id") != user_id:
                return False

            last_evaluated_key = None

            while True:
                query_kwargs = {
                    "KeyConditionExpression": Key("chat_id").eq(chat_id),
                    "ProjectionExpression": "chat_id, message_id"
                }

                if last_evaluated_key:
                    query_kwargs["ExclusiveStartKey"] = last_evaluated_key

                messages_response = self._messages_table.query(**query_kwargs)

                with self._messages_table.batch_writer() as batch:
                    for it in messages_response.get("Items", []):
                        batch.delete_item(
                            Key = {
                                "chat_id": it["chat_id"],
                                "message_id": it["message_id"]
                            }
                        )

                last_evaluated_key = messages_response.get("LastEvaluatedKey")
                if not last_evaluated_key:
                    break
            
            self._chats_table.delete_item(
                Key = {"chat_id": chat_id}
            )

            return True

        except ClientError as e:
            raise RuntimeError(f"Error in deleting chat: {e.response['Error']['Message']}")

    def add_chat_message(self, user_id: str, chat_id: str, text: str, sender: str) -> None:
        try:
            if sender != "user" and sender != "ai":
                raise ValueError("Message sender must be 'user' or 'ai'")

            chat_response = self._chats_table.get_item(
                Key = {"chat_id": chat_id},
                ConsistentRead = True
            )

            chat_item = chat_response.get("Item")
            if not chat_item or chat_item.get("user_id") != user_id:
                raise ValueError("Chat not found or with missing authorization")

            message_id = self._new_message_id()
            created_at = self._now_iso()

            self._messages_table.put_item(
                Item = {
                    "chat_id": chat_id,
                    "message_id": message_id,
                    "text": text,
                    "sender": sender,
                    "created_at": created_at
                }
            )

        except ClientError as e:
            raise RuntimeError(f"Error adding new chat message: {e.response['Error']['Message']}")

    def list_chats(self, user_id: str) -> List[Chat]:
        chats_response = self._chats_table.query(
            IndexName = "user_index",
            KeyConditionExpression = Key("user_id").eq(user_id)
        )

        chats: List[Chat] = []

        for item in chats_response.get("Items", []):
            chats.append(
                Chat(
                    title = item["title"],
                    chat_id = item["chat_id"],
                    user_id = item["user_id"],
                    created_at = item.get("created_at"),
                    updated_at = item.get("updated_at"),
                    messages = []
                )
            )

        return chats