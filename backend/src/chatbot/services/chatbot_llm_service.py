from chatbot.ports.chatbot_llm_port import ChatbotLLMPort
from chatbot.domain.chat import Chat
from rank_bm25 import BM25Okapi
from pathlib import Path
import re

class ChatbotLLMService:
    def __init__(self, model: ChatbotLLMPort, top_k: int = 5):
        self.model = model
        self.top_k = top_k
        self._base_prompt = self._load_prompt("base_prompt.txt")
        self._detective_prompt = self._load_prompt("detective_prompt.txt")
        self._mirror_prompt = self._load_prompt("mirror_prompt.txt")

    def _tokenize(self, text: str):
        return re.findall(r"\b\w+\b", text.lower())

    def _build_corpus(self, chat: Chat):
        corpus = []
        messages = []
        for m in chat.messages:
            tokens = self._tokenize(m.text)
            corpus.append(tokens)
            messages.append(m.text)
        return corpus, messages

    def _retrieve_relevant_messages(self, chat: Chat, query: str):
        if not chat.messages:
            return []

        corpus, raw_messages = self._build_corpus(chat)
        bm25 = BM25Okapi(corpus)

        query_tokens = self._tokenize(query)
        scores = bm25.get_scores(query_tokens)

        ranked = sorted(enumerate(scores), key=lambda x: x[1], reverse=True)
        top_indices = [i for i, _ in ranked[:self.top_k]]

        return [raw_messages[i] for i in top_indices]

    def _load_prompt(self, filename: str, base_path: str = "prompts") -> str:
        base_dir = Path(__file__).resolve().parents[1]
        path = base_dir / base_path / filename
        return path.read_text(encoding="utf-8")

    def _build_prompt(self, chat: Chat, message: str, response_mode: str):
        # Prompt di sistema = prompt base + prompt modalità chatbot
        mode_prompt = ""
        if response_mode == "detective":
            mode_prompt = self._detective_prompt
        elif response_mode == "mirror":
            mode_prompt = self._mirror_prompt

        system_prompt = f"{mode_prompt}\n\n{self._base_prompt}"

        relevant_messages = self._retrieve_relevant_messages(chat, message)

        # Blocco di contesto, con i messaggi più rilevanti inviati dall'utente
        context_block = ""
        if relevant_messages:
            context_block = "\n".join(relevant_messages)
            context_block = f"RELEVANT CONVERSATION CONTEXT:\n{context_block}\n"

        # Prompt finale
        return f"""{system_prompt}

        {context_block}
        USER MESSAGE:
        {message}
        """

    def get_message_response(self, chat: Chat, message: str, response_mode: str) -> str:
        prompt = self._build_prompt(chat, message, response_mode)
        print(prompt)
        return self.model.process_prompt(chat, prompt, response_mode)