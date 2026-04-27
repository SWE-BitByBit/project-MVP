from abc import ABC, abstractmethod
from domain.chat import Chat

class ChatbotLLMPort(ABC):
    @abstractmethod
    def process_prompt(self, chat: Chat, prompt: str, response_mode: str) -> str:
        pass
