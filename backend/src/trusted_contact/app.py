from trusted_contact_controller import TrustedContactController

def lambda_handler(event, context):
    controller = TrustedContactController()
    controller.handle_request(context=context, event=event)