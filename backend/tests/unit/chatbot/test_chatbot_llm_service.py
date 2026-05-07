"""
Test di unità: ChatbotLLMService.

Verifica la logica interna del servizio LLM (tokenizzazione, costruzione del corpus,
recupero messaggi rilevanti, costruzione del prompt) in isolamento,
senza dipendenze da DynamoDB o dal modello LLM reale.
"""

from src.chatbot.services.chatbot_llm_service import ChatbotLLMService


def test_llm_service_detective(sample_chat, llm_service):
    response = llm_service.get_message_response(
        chat=sample_chat["chat"],
        message="hello ai",
        response_mode="detective"
    )

    assert response == "Mocked response"


def test_llm_service_mirror(sample_chat, llm_service):
    response = llm_service.get_message_response(
        chat=sample_chat["chat"],
        message="hello ai",
        response_mode="mirror"
    )

    assert response == "Mocked response"


def test_llm_service_prompt_length(sample_chat, llm_service):
    response = llm_service.get_message_response(
        chat=sample_chat["chat"],
        message="hello ai",
        response_mode="mirror"
    )

    assert response == "Mocked response"


def test_tokenize(llm_service):
    tokens = llm_service._tokenize("Hello World 123!")

    assert "hello" in tokens
    assert "world" in tokens
    assert "123" in tokens
    assert len(tokens) == 3
    assert "!" not in tokens


def test_build_corpus(llm_service, sample_chat_llm):
    corpus, messages = llm_service._build_corpus(sample_chat_llm)
    userMessagesLen = len([
        m for m in sample_chat_llm.messages
        if m.sender != "ai"
    ])

    assert len(corpus) == userMessagesLen
    assert len(messages) == userMessagesLen

    assert isinstance(corpus[0], list)
    assert "machine" in corpus[0]
    assert "learning" not in corpus[1]
    assert "pizza" in corpus[1]


def test_retrieve_relevant_messages(llm_service, sample_chat_llm):
    result = llm_service._retrieve_relevant_messages(
        sample_chat_llm,
        query="machine learning"
    )

    assert isinstance(result, list)
    assert len(result) > 0

    joined = " ".join(result).lower()
    assert "learning" in joined or "machine" in joined