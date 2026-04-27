import json

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

UNAUTHORIZED = {"message": "Unauthorized"}
ROUTE_NOT_FOUND = {"message": "Route not found"}
SERVER_ERROR = {"message": "Internal server error"}


class TrustedContactController:

    def __init__(
            self,
            dms_crud_service: DmsCRUDService,
            dms_alert_service: DmsAlertService,
            trusted_contact_crud_service: TrustedContactCRUDService,
            sos_alert_service: SOSAlertService  
        ):
            self._dms_crud_service = dms_crud_service
            self._dms_alert_service = dms_alert_service
            self._trusted_contact_crud_service = trusted_contact_crud_service
            self._sos_alert_service = sos_alert_service

    def handle_request(self, event, context):
        method = self._get_method(event)
        user_id = self._get_user_id(event)
        parts = self._split_path(event)
        body = self._parse_body(event)

        if not user_id:
            return self._response(401, UNAUTHORIZED)
        
        if parts[0] == "dms_settings":
            return self._route_dms_settings(method, parts, user_id, body)
        elif parts[0] == "trusted_contact":
            return self._route_trusted_contact(method, parts, user_id, body)
        elif parts[0] == "alert":
            return self._route_alert(method, user_id, body)
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
    
    def _route_dms_settings(self, method, parts, user_id, body):
        
        if method == "POST":
            return self._handle_dms_settings_create(user_id)
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
        
    
    def _route_alert(self, method, user_id, body):

        if method == "PUT":
            return self._handle_alert(user_id, body)
        else:
            return self._response(404, ROUTE_NOT_FOUND)
    

    def _handle_dms_settings_create(self, user_id):

        dms_settings = self._dms_crud_service.create_dms_configuration_settings(user_id)
        if not dms_settings:
            return self._response(500, SERVER_ERROR)
        dms_settings_dto = DmsConfigurationSettingsDTO.from_domain(dms_settings)

        return self._response(200, dms_settings_dto.to_dict())
    

    def _handle_dms_settings_get(self, user_id):

        dms_settings = self._dms_crud_service.get_dms_config(user_id)
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
        self._dms_crud_service.update_dms_configuration_settings(new_dms_settings)

        return self._response(204, {})


    def _handle_heartbeat_update(self, user_id):
        self._dms_crud_service.send_heartbeat(user_id)

        return self._response(204, {})
    

    def _handle_trusted_contact_create(self, user_id, body):
        new_trusted_contact_cmd = AddTrustedContactCmd(
            user_id=user_id,
            contact_name=body.get("contact_name"),
            contact_email=body.get("contact_email"),
            contact_phone_number=body.get("contact_phone_number")
        )
        new_trusted_contact = self._trusted_contact_crud_service.add_trusted_contact(new_trusted_contact_cmd)

        if not new_trusted_contact:
            return self._response(500, SERVER_ERROR)
        new_trusted_contact_dto = TrustedContactDTO.from_domain(new_trusted_contact)

        return self._response(200, new_trusted_contact_dto.to_dict())
    

    def _handle_trusted_contact_update(self, user_id, body):
        to_update_trusted_contact = TrustedContact(
            user_id=user_id,
            contact_id=body.get("contact_id"),
            contact_name=body.get("contact_name"),
            contact_email=body.get("contact_email"),
            contact_phone_number=body.get("contact_phone_number")
        )

        updated_trusted_contact = self._trusted_contact_crud_service.update_trusted_contact(to_update_trusted_contact)

        if not updated_trusted_contact:
            return self._response(500, SERVER_ERROR)
        new_trusted_contact_dto = TrustedContactDTO.from_domain(updated_trusted_contact)
        
        return self._response(200, new_trusted_contact_dto.to_dict())
    

    def _handle_trusted_contact_get(self, user_id, contact_id):
        get_trusted_contact_cmd = GetTrustedContactCmd(
            user_id=user_id,
            contact_id=contact_id
        )
        trusted_contact = self._trusted_contact_crud_service.get_trusted_contact(get_trusted_contact_cmd)

        if not trusted_contact:
            return self._response(500, SERVER_ERROR)
        trusted_contact_dto = TrustedContactDTO.from_domain(trusted_contact)
        
        return self._response(200, trusted_contact_dto.to_dict())
    

    def _handle_trusted_contact_get_all(self, user_id):
        contacts = self._trusted_contact_crud_service.get_all_trusted_contact(user_id)
        return self._response(200, {"trusted_contacts": [t.__dict__ for t in contacts]})
    

    def _handle_trusted_contract_delete(self, user_id, contact_id):
        to_delete_trusted_contact_cmd = DeleteTrustedContactCmd(
            user_id=user_id,
            contact_id=contact_id
        )
        response = self._trusted_contact_crud_service.delete_trusted_contact(to_delete_trusted_contact_cmd)
        if response:
            return self._response(200, {})
        else:
            return self._response(500, SERVER_ERROR)
        
    
    def _handle_alert(self, user_id, body):
        alert_cmd = AlertCmd(
            user_id=user_id,
            user_name=body.get("user_name"),
            latitude=body.get("latitude"),
            longitude=body.get("longitude")
        )

        response = self._sos_alert_service.send_alert_emails(alert_cmd)
        if response:
            return self._response(200, {})
        else:
            return self._response(500, SERVER_ERROR)