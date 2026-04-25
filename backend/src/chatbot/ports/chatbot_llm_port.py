from abc import ABC, abstractmethod
from chatbot.domain.chat import Chat

class ChatbotLLMPort(ABC):
    @abstractmethod
    def process_prompt(self, chat: Chat, prompt: str, response_mode: str) -> str:
        pass