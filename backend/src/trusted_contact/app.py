from trusted_contact_controller import TrustedContactController

def lambda_handler(event, context):
    controller = TrustedContactController()
    return controller.handle_request(context=context, event=event)