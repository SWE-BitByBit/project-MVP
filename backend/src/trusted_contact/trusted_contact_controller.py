import json
import re

from domain.dms_configuration_settings import DmsConfigurationSettings
from domain.dtos.dms_configuration_settings_dto import DmsConfigurationSettingsDTO
from commands.add_trusted_contact_command import AddTrustedContactCmd
from domain.dtos.trusted_contact_dto import TrustedContactDTO
from domain.trusted_contact import TrustedContact
from commands.get_trusted_contact_command import GetTrustedContactCmd
from commands.delete_trusted_contact_command import DeleteTrustedContactCmd
from commands.alert_command import AlertCmd

from services.dms_alert_service import DmsAlertService
from services.dms_crud_service import DmsCRUDService
from services.sos_alert_service import SOSAlertService
from services.trusted_contact_crud_service import TrustedContactCRUDService

from adapters.dynamo_dms_adapter import DynamoDmsAdapter
from adapters.dynamo_trusted_contact_adapter import DynamoTrustedContactAdapter
from adapters.ses_notification_adapter import SesNotificationAdapter

UNAUTHORIZED = {"message": "Unauthorized"}
ROUTE_NOT_FOUND = {"message": "Route not found"}
SERVER_ERROR = {"message": "Internal server error"}
SCHEDULER_SUCCESS = {"body": "Scheduled job executed"}
SCHEDULER_ERROR = {"message": "Scheduler failed"}

class TrustedContactController:

    def __init__(self):
            self._dms_crud_service = None
            self._dms_alert_service = None
            self._trusted_contact_crud_service = None
            self._sos_alert_service = None


    def _get_dms_crud_service(self) -> DmsCRUDService:
        if not self._dms_crud_service:
            dynamo_dms_repository = DynamoDmsAdapter()
            self._dms_crud_service = DmsCRUDService(dynamo_dms_repository)
        return self._dms_crud_service


    def _get_trusted_contact_crud_service(self) -> TrustedContactCRUDService:
        if not self._trusted_contact_crud_service:
            dynamo_trusted_contact_repository = DynamoTrustedContactAdapter()
            self._trusted_contact_crud_service = TrustedContactCRUDService(
                dynamo_trusted_contact_repository
            )
        return self._trusted_contact_crud_service


    def _get_sos_alert_service(self) -> SOSAlertService:
        if not self._sos_alert_service:
            dynamo_trusted_contact_repository = DynamoTrustedContactAdapter()
            ses_repository = SesNotificationAdapter()
            self._sos_alert_service = SOSAlertService(
                dynamo_trusted_contact_repository,
                ses_repository
            )
        return self._sos_alert_service


    def _get_dms_alert_service(self) -> DmsAlertService:
        if not self._dms_alert_service:
            dynamo_dms_repository = DynamoDmsAdapter()
            dynamo_trusted_contact_repository = DynamoTrustedContactAdapter()
            ses_repository = SesNotificationAdapter()
            self._dms_alert_service = DmsAlertService(
                dynamo_trusted_contact_repository,
                ses_repository,
                dynamo_dms_repository
            )
        return self._dms_alert_service

    def handle_request(self, event, context):
        method = self._get_method(event)
        user_id = self._get_user_id(event)
        parts = self._split_path(event)
        body = self._parse_body(event)
        user_name = self._get_user_name(event)
        user_email = self._get_user_email(event)

        if not user_id:
            return self._response(401, UNAUTHORIZED)

        if event.get("source") in ["aws.events", "aws.scheduler"]:
            return self._handle_scheduled_event()
        
        if parts[0] == "dms_settings":
            return self._route_dms_settings(method, parts, user_id, user_email, user_name, body)
        elif parts[0] == "trusted_contact":
            return self._route_trusted_contact(method, parts, user_id, body)
        elif parts[0] == "alert":
            return self._route_alert(method, user_id, user_name, body)
        else:
            return self._response(404, ROUTE_NOT_FOUND)
    

    def _parse_body(self, event):
        try:
            body = event.get("body")
            if not body:
                return {}
            return json.loads(body)
        except json.JSONDecodeError:
            return {}


    def _get_method(self, event):
        return (
            event.get("requestContext", {})
            .get("http", {})
            .get("method")
        )


    def _get_path(self, event):
        return event.get("rawPath", "")


    def _split_path(self, event):
        stage_path = ['mvp']
        path = self._get_path(event)
        path = [p for p in path.split("/") if p]
        if (len(path)>1 and path[0] in stage_path):
            return path[1:]
        else:
            return path


    def _get_user_id(self, event):
        claims = (
            event.get("requestContext", {})
            .get("authorizer", {})
            .get("jwt", {})
            .get("claims", {})
        )

        return claims.get("sub")
    

    def _get_user_name(self, event):
        claims = (
            event.get("requestContext", {})
            .get("authorizer", {})
            .get("jwt", {})
            .get("claims", {})
        )

        return claims.get("given_name", "")
    

    def _get_user_email(self, event):
        claims = (
            event.get("requestContext", {})
            .get("authorizer", {})
            .get("jwt", {})
            .get("claims", {})
        )

        return claims.get("email", "")
    
    def _validate_trusted_contact_input(self, body):
        errors = {}

        email = body.get("contact_email")
        phone = body.get("contact_phone_number")

        email_regex = r"^[\w\.-]+@[\w\.-]+\.\w+$"
        if not email or not re.match(email_regex, email):
            errors["contact_email"] = "Invalid email format"

        phone_regex = r"^[0-9+\-\s]{7,15}$"
        if not phone or not re.match(phone_regex, phone):
            errors["contact_phone_number"] = "Invalid phone number format"

        return errors


    def _response(self, status_code, body):
        if status_code == 204:
            return {
                "statusCode": status_code,
                "headers": {"Content-Type": "application/json"},
                "body": ""
            }

        return {
            "statusCode": status_code,
            "headers": {"Content-Type": "application/json"},
            "body": json.dumps(body)
        }
    
    def _route_dms_settings(self, method, parts, user_id, user_email, user_name, body):
        
        if method == "POST":
            return self._handle_dms_settings_create(user_id, user_email, user_name)
        elif method == "GET":
            return self._handle_dms_settings_get(user_id)
        elif method == "PUT" and len(parts) > 1 and parts[1] == "heartbeat":
                return self._handle_heartbeat_update(user_id)
        elif method == "PUT":
            return self._handle_dms_settings_update(user_id, body)
        else:
            return self._response(404, ROUTE_NOT_FOUND)


    def _route_trusted_contact(self, method, parts, user_id, body):

        if method == "POST":
            return self._handle_trusted_contact_create(user_id, body)
        elif method == "PUT":
            return self._handle_trusted_contact_update(user_id, body)
        elif method == "GET" and len(parts) > 1 and parts[1]:
            return self._handle_trusted_contact_get(user_id, parts[1])
        elif method == "GET":
            return self._handle_trusted_contact_get_all(user_id)
        elif method == "DELETE" and len(parts) > 1 and parts[1]:
            return self._handle_trusted_contract_delete(user_id, parts[1])
        else:
            return self._response(404, ROUTE_NOT_FOUND)
        
    
    def _route_alert(self, method, user_id, user_name, body):

        if method == "PUT":
            return self._handle_alert(user_id, user_name, body)
        else:
            return self._response(404, ROUTE_NOT_FOUND)
        
    
    def _handle_scheduled_event(self):
        response = self._get_dms_alert_service().update_dms_timers()

        if response:
            return self._response(200, SCHEDULER_SUCCESS)
        else:
            return self._response(500, SCHEDULER_ERROR)
    

    def _handle_dms_settings_create(self, user_id, user_email, user_name):

        dms_settings = self._get_dms_crud_service().create_dms_configuration_settings(user_id, user_email, user_name)
        if not dms_settings:
            return self._response(500, SERVER_ERROR)
        dms_settings_dto = DmsConfigurationSettingsDTO.from_domain(dms_settings)

        return self._response(200, dms_settings_dto.to_dict())
    

    def _handle_dms_settings_get(self, user_id):

        dms_settings = self._get_dms_crud_service().get_dms_config(user_id)
        if not dms_settings:
            return self._response(500, SERVER_ERROR)
        dms_settings_dto = DmsConfigurationSettingsDTO.from_domain(dms_settings)

        return self._response(200, dms_settings_dto.to_dict())
    

    def _handle_dms_settings_update(self, user_id, body):
        new_dms_settings = DmsConfigurationSettings(
            user_id=user_id,
            is_active=body.get("is_active"),
            first_timer=body.get("first_timer"),
            second_timer=body.get("second_timer"),
            email_subject=body.get("email_subject"),
            email_body=body.get("email_body")
        )
        self._get_dms_crud_service().update_dms_configuration_settings(new_dms_settings)
        dms_settings_dto = DmsConfigurationSettingsDTO.from_domain(new_dms_settings)

        return self._response(204, dms_settings_dto.to_dict())


    def _handle_heartbeat_update(self, user_id):
        self._get_dms_crud_service().send_heartbeat(user_id)

        return self._response(204, {"message": "Heartbeat processed with success"})
    

    def _handle_trusted_contact_create(self, user_id, body):

        errors = self._validate_trusted_contact_input(body)
        if errors:
            return self._response(400, {
                "message": "Validation error",
                "errors": errors
            })
        
    
        new_trusted_contact_cmd = AddTrustedContactCmd(
            user_id=user_id,
            contact_name=body.get("contact_name"),
            contact_email=body.get("contact_email"),
            contact_phone_number=body.get("contact_phone_number")
        )
        try:
            new_trusted_contact = self._get_trusted_contact_crud_service().add_trusted_contact(new_trusted_contact_cmd)
        except ValueError as e:
            return self._response(409, {"message": str(e)})

        if not new_trusted_contact:
            return self._response(500, SERVER_ERROR)
        new_trusted_contact_dto = TrustedContactDTO.from_domain(new_trusted_contact)

        return self._response(200, new_trusted_contact_dto.to_dict())
    

    def _handle_trusted_contact_update(self, user_id, body):

        errors = self._validate_trusted_contact_input(body)
        if errors:
            return self._response(400, {
                "message": "Validation error",
                "errors": errors
            })

        to_update_trusted_contact = TrustedContact(
            user_id=user_id,
            contact_id=body.get("contact_id"),
            contact_name=body.get("contact_name"),
            contact_email=body.get("contact_email"),
            contact_phone_number=body.get("contact_phone_number")
        )

        try:
            updated_trusted_contact = self._get_trusted_contact_crud_service().update_trusted_contact(to_update_trusted_contact)
        except ValueError as e:
            return self._response(409, {"message": str(e)})

        if not updated_trusted_contact:
            return self._response(500, SERVER_ERROR)
        updated_trusted_contact_dto = TrustedContactDTO.from_domain(updated_trusted_contact)
        
        return self._response(200, updated_trusted_contact_dto.to_dict())
    

    def _handle_trusted_contact_get(self, user_id, contact_id):
        get_trusted_contact_cmd = GetTrustedContactCmd(
            user_id=user_id,
            contact_id=contact_id
        )
        trusted_contact = self._get_trusted_contact_crud_service().get_trusted_contact(get_trusted_contact_cmd)

        if not trusted_contact:
            return self._response(500, SERVER_ERROR)
        trusted_contact_dto = TrustedContactDTO.from_domain(trusted_contact)
        
        return self._response(200, trusted_contact_dto.to_dict())
    

    def _handle_trusted_contact_get_all(self, user_id):
        contacts = self._get_trusted_contact_crud_service().get_all_trusted_contact(user_id)
        return self._response(200, {"trusted_contacts": [t.__dict__ for t in contacts]})
    

    def _handle_trusted_contract_delete(self, user_id, contact_id):
        to_delete_trusted_contact_cmd = DeleteTrustedContactCmd(
            user_id=user_id,
            contact_id=contact_id
        )
        response = self._get_trusted_contact_crud_service().delete_trusted_contact(to_delete_trusted_contact_cmd)
        if response:
            return self._response(200, {"message": f"Contact {contact_id} deleted"})
        else:
            return self._response(500, SERVER_ERROR)
        
    
    def _handle_alert(self, user_id, user_name, body):
        alert_cmd = AlertCmd(
            user_id=user_id,
            user_name=user_name,
            latitude=body.get("latitude"),
            longitude=body.get("longitude")
        )

        trusted_contacts = self._get_trusted_contact_crud_service().get_all_trusted_contact(user_id)
        if not trusted_contacts:
            return self._response(400, {"message": "No contacts to send the alert"})

        response = self._get_sos_alert_service().send_alert_emails(alert_cmd)
        if response:
            return self._response(200, {"message": "Alert send processed with success"})
        else:
            return self._response(500, SERVER_ERROR)