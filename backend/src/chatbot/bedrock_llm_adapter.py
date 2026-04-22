from chatbot_llm_port import ChatbotLLMPort
from chat import Chat
import random
import string


class BedrockLLMAdapter(ChatbotLLMPort):
    def process_prompt(self, chat: Chat, prompt: str, response_mode: str) -> str:
        words = [
            ''.join(random.choices(string.ascii_lowercase, k=random.randint(3, 10)))
            for _ in range(random.randint(5, 25))
        ]
        return " ".join(words)