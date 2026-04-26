import pytest
import boto3
import os
from moto import mock_aws

from src.trusted_contact.adapters.dynamo_dms_adapter import DynamoDmsAdapter
from src.trusted_contact.domain.dms_configuration_settings import DmsConfigurationSettings

@pytest.fixture
def setup_mock_dynamo():
    with mock_aws():
        dynamodb = boto3.resource("dynamodb", region_name="us-east-1")
        table = dynamodb.create_table(
            TableName="dms_table",
            KeySchema=[
                {"AttributeName": "user_id", "KeyType": "HASH"}
            ],
            AttributeDefinitions=[
                {"AttributeName": "user_id", "AttributeType": "S"}
            ],
            BillingMode="PAY_PER_REQUEST"
        )
        table.put_item(
            Item={
                "user_id": "user1",
                "is_active": True,
                "first_timer": 60,
                "second_timer": 120,
                "email_subject": "Messaggio di emergenza",
                "email_body": "Corpo del messaggio",
                "first_timer_count_down": 60,
                "second_timer_count_down": 120,
            }
        )
        table.wait_until_exists()
        os.environ["DMS_TABLE"] = "dms_table"
        os.environ["REGION"] = "us-east-1"
        yield DynamoDmsAdapter()


@pytest.fixture
def sample_config():
    return DmsConfigurationSettings(
        user_id="user2",
        is_active=False,
        first_timer=30,
        second_timer=60,
        email_subject="Soggetto test",
        email_body="Corpo test"
    )


def test_get_dms_config(setup_mock_dynamo):
    adapter = setup_mock_dynamo
    result = adapter.get_dms_config("user1")

    assert result is not None
    assert result.user_id == "user1"
    assert result.is_active == True
    assert result.first_timer == 60
    assert result.second_timer == 120
    assert result.email_subject == "Messaggio di emergenza"
    assert result.email_body == "Corpo del messaggio"


def test_get_dms_config_not_found(setup_mock_dynamo):
    adapter = setup_mock_dynamo

    with pytest.raises(KeyError):
        adapter.get_dms_config("nonexistent_user")


def test_add_dms_config(setup_mock_dynamo):
    adapter = setup_mock_dynamo
    result = adapter.add_dms_config("user2")

    assert result is not None
    assert result.user_id == "user2"
    assert result.is_active == False
    assert result.first_timer == 0
    assert result.second_timer == 0
    assert result.email_subject == ""
    assert result.email_body == ""


def test_update_dms_config(setup_mock_dynamo):
    adapter = setup_mock_dynamo

    updated_config = DmsConfigurationSettings(
        user_id="user1",
        is_active=False,
        first_timer=90,
        second_timer=180,
        email_subject="Nuovo soggetto",
        email_body="Nuovo corpo"
    )
    adapter.update_dms_config(updated_config)
    result = adapter.get_dms_config("user1")

    assert result.is_active == False
    assert result.first_timer == 90
    assert result.second_timer == 180
    assert result.email_subject == "Nuovo soggetto"
    assert result.email_body == "Nuovo corpo"


def test_update_dms_config_not_found(setup_mock_dynamo, sample_config):
    adapter = setup_mock_dynamo

    with pytest.raises(KeyError):
        adapter.update_dms_config(sample_config)


def test_get_first_timer(setup_mock_dynamo):
    adapter = setup_mock_dynamo
    result = adapter.get_first_timer("user1")

    assert result == 60


def test_get_second_timer(setup_mock_dynamo):
    adapter = setup_mock_dynamo
    result = adapter.get_second_timer("user1")

    assert result == 120


def test_get_timer_not_found(setup_mock_dynamo):
    adapter = setup_mock_dynamo

    with pytest.raises(KeyError):
        adapter.get_first_timer("nonexistent_user")


def test_update_first_counter(setup_mock_dynamo):
    adapter = setup_mock_dynamo
    adapter.update_first_counter("user1", 45)
    result = adapter.get_first_timer("user1")

    assert result == 45


def test_update_second_counter(setup_mock_dynamo):
    adapter = setup_mock_dynamo
    adapter.update_second_counter("user1", 90)
    result = adapter.get_second_timer("user1")

    assert result == 90