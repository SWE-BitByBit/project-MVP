from adapters.dynamo_dms_adapter import DynamoDmsAdapter
from adapters.dynamo_trusted_contact_adapter import DynamoTrustedContactAdapter
from adapters.ses_notification_adapter import SesNotificationAdapter

from services.dms_crud_service import DmsCRUDService
from services.dms_alert_service import DmsAlertService
from services.trusted_contact_crud_service import TrustedContactCRUDService
from services.sos_alert_service import SOSAlertService

from trusted_contact_controller import TrustedContactController

def lambda_handler(event, context):

    dynamo_dms_repository = DynamoDmsAdapter()
    dynamo_trusted_contact_repository = DynamoTrustedContactAdapter()
    ses_repository = SesNotificationAdapter()

    dms_crud_service = DmsCRUDService(dynamo_dms_repository)
    dms_alert_service = DmsAlertService(dynamo_trusted_contact_repository, ses_repository, dynamo_dms_repository)
    trusted_contact_crud_service = TrustedContactCRUDService(dynamo_trusted_contact_repository)
    sos_alert_service = SOSAlertService(dynamo_trusted_contact_repository, ses_repository)

    controller = TrustedContactController(
        dms_crud_service=dms_crud_service,
        dms_alert_service=dms_alert_service,
        trusted_contact_crud_service=trusted_contact_crud_service,
        sos_alert_service=sos_alert_service
    )

    controller.handle_request(context=context, event=event)