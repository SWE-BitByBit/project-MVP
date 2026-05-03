import pytest
import boto3
import os
from moto import mock_aws

from src.trusted_contact.domain.trusted_contact import TrustedContact
from src.trusted_contact.adapters.dynamo_trusted_contact_adapter import DynamoTrustedContactAdapter

@pytest.fixture
def setup_mock_dynamo():
    with mock_aws():

        dynamodb = boto3.resource("dynamodb", region_name="us-east-1")
        table = dynamodb.create_table(
            TableName="test_trusted_contact_table",
            KeySchema=[
                {"AttributeName": "user_id", "KeyType": "HASH"},
                {"AttributeName": "contact_id", "KeyType": "RANGE"},
            ],
            AttributeDefinitions=[
                {"AttributeName": "user_id", "AttributeType": "S"},
                {"AttributeName": "contact_id", "AttributeType": "S"},
            ],
            BillingMode="PAY_PER_REQUEST"
        )

        table.put_item(
            Item={
                "user_id":"user1",
                "contact_id":"contact1",
                "contact_name":"Tywin",
                "contact_email": "tywin@gmail.com",
                "contact_phone_number": "111 1111 111"
            }
        )
        table.put_item(
            Item={
                "user_id": "user1",
                "contact_id": "contact3", 
                "contact_name": "Cersei", 
                "contact_email": "cersei@gmail.com", 
                "contact_phone_number": "333 2222 222"
            }
        )
        table.put_item(
            Item={
                "user_id": "user1", 
                "contact_id": "contact4", 
                "contact_name": "Jaime", 
                "contact_email": "jaime@gmail.com", 
                "contact_phone_number": "333 3333 333"
            }
        )

        table.wait_until_exists()
        os.environ["TRUSTED_CONTACT_TABLE"] = "test_trusted_contact_table"
        os.environ["REGION"] = "us-east-1"
        yield DynamoTrustedContactAdapter()


@pytest.fixture
def sample_contact():
    return TrustedContact(
        user_id="user2",
        contact_id="contact2",
        contact_name="Tyrion",
        contact_email="tyrion@gmail.com",
        contact_phone_number="333 3333 333"
    )


def test_add_contact(setup_mock_dynamo, sample_contact):
    adapter = setup_mock_dynamo
    result = adapter.add(sample_contact)

    assert result is not None
    assert result.contact_id == "contact2"
    assert result.contact_name == "Tyrion"
    assert result.contact_email == "tyrion@gmail.com"
    assert result.contact_phone_number == "333 3333 333"


def test_get_contact(setup_mock_dynamo):
    adapter = setup_mock_dynamo
    result = adapter.get("user1", "contact1")

    assert result is not None
    assert result.contact_id == "contact1"
    assert result.contact_name == "Tywin"
    assert result.contact_email == "tywin@gmail.com"


def test_get_contact_not_found(setup_mock_dynamo):
    adapter = setup_mock_dynamo
    result = adapter.get("user1", "nonexistent_id")

    assert result is None


def test_delete_contact(setup_mock_dynamo):
    adapter = setup_mock_dynamo
    adapter.delete("user1", "contact1")
    result = adapter.get("user1", "contact1")

    assert result is None


def test_delete_contact_not_found(setup_mock_dynamo):
    adapter = setup_mock_dynamo

    with pytest.raises(KeyError):
        adapter.delete("user1", "nonexistent_id")


def test_update_contact(setup_mock_dynamo, sample_contact):
    adapter = setup_mock_dynamo
    adapter.add(sample_contact)

    updated_contact = TrustedContact(
        user_id="user1",
        contact_id="contact1",
        contact_name="Tywin Lannister",
        contact_email="tywin.lannister@gmail.com",
        contact_phone_number="333 0000 000"
    )
    adapter.update(updated_contact)
    result = adapter.get("user1", "contact1")

    assert result.contact_name == "Tywin Lannister"
    assert result.contact_email == "tywin.lannister@gmail.com"
    assert result.contact_phone_number == "333 0000 000"


def test_update_contact_not_found(setup_mock_dynamo, sample_contact):
    adapter = setup_mock_dynamo

    with pytest.raises(KeyError):
        adapter.update(sample_contact)


def test_list_contacts(setup_mock_dynamo):
    adapter = setup_mock_dynamo

    result = adapter.list("user1")

    assert len(result) == 3
    assert any(c.contact_id == "contact1" for c in result)
    assert any(c.contact_id == "contact3" for c in result)
    assert any(c.contact_id == "contact4" for c in result)


def test_list_contacts_empty(setup_mock_dynamo):
    adapter = setup_mock_dynamo
    result = adapter.list("user_with_no_contacts")

    assert result == []
