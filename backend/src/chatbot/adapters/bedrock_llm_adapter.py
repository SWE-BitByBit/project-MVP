import secrets
from chatbot.ports.chatbot_llm_port import ChatbotLLMPort
from chatbot.domain.chat import Chat

class BedrockLLMAdapter(ChatbotLLMPort):
    def process_prompt(self, chat: Chat, prompt: str, response_mode: str) -> str:
        # Usiamo una lista di risposte predefinite per simulare l'AI senza usare random()
        # che fa arrabbiare SonarQube per motivi di sicurezza.
        mock_responses = [
            "Capisco perfettamente quello che stai provando. Vuoi approfondire?",
            "Interessante punto di vista. Come ti fa sentire questa situazione?",
            "Sono qui per ascoltarti. Continua pure a raccontarmi.",
            "Questa è una riflessione molto profonda. Grazie per averla condivisa.",
            "Analizzando quello che dici, sembra che ci sia molto su cui lavorare insieme."
        ]
        
        # Selezioniamo una risposta in modo sicuro con secrets
        return secrets.choice(mock_responses)