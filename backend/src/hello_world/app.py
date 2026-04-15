import json
import boto3
import os

def response(status, body):
        return {
            "statusCode": status,
            "headers": {"Content-Type": "application/json"},
            "body": json.dumps(body)
        }

def get_contact(table, event):
    """funzione per il fetch di un contatto"""
    contact_id = event["pathParameters"]["contact_id"]
    db_response = table.get_item(
        Key={
            "user_id": event["requestContext"]["authorizer"]["jwt"]["claims"]["sub"],
            "contact_id": contact_id
        }
    )
    item = db_response.get("Item")
    if not item:
        return response(404, {"msg": "Not found"})
    return response(200, item)

def lambda_handler(event, context):
    """ Handler della lambda"""
    dynamodb = boto3.resource("dynamodb", region_name="eu-south-1")
    table = dynamodb.Table(os.environ["TABLE_NAME"])

    if event.get("routeKey") ==  "GET /contacts/{contact_id}":
        return get_contact(table, event)