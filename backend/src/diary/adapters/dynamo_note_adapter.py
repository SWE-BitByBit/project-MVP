import boto3

class DynamoNoteAdapter:

    def __init__(self, table_name):
        self.table = boto3.resource('dynamodb').Table(table_name)

    def add(self, note):
        self.table.put_item(Item=note.__dict__)

    def get(self, user_id, note_id, diary_type):
        res = self.table.get_item(
            Key={
                "user_id": user_id,
                "note_id": note_id
            }
        )
        return res.get("Item")