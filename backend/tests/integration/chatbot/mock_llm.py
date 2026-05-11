from src.chatbot.domain.chat import Chat

class MockLLM():
    def process_prompt(self, chat: Chat, prompt: str, response_mode: str) -> str:
        return "Mocked response"
