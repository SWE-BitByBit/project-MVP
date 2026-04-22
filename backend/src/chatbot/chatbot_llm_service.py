from chatbot_llm_port import ChatbotLLMPort
from chat import Chat

class ChatbotLLMService:
    def __init__(self, model: ChatbotLLMPort):
        self.model = model

    def get_prompt_response(self, chat: Chat, prompt: str, response_mode: str) -> str:
        return self.model.process_prompt(chat, prompt, response_mode)