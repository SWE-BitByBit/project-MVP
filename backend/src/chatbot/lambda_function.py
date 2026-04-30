from adapters.dynamo_chat_adapter import DynamoChatAdapter
from adapters.bedrock_llm_adapter import BedrockLLMAdapter
from services.chatbot_crud_service import ChatbotCRUDService
from services.chatbot_llm_service import ChatbotLLMService
from controller import ChatbotController

_controller = None


def get_controller():
    global _controller
    if _controller is None:
        crud_service = ChatbotCRUDService(DynamoChatAdapter())
        llm_service = ChatbotLLMService(BedrockLLMAdapter())
        _controller = ChatbotController(crud_service, llm_service)
    return _controller


def lambda_handler(event, context):
    return get_controller().handle(event)