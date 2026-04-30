import boto3

from ports.chatbot_llm_port import ChatbotLLMPort
from domain.chat import Chat

class BedrockLLMAdapter(ChatbotLLMPort):
    def __init__(self):
        self.client = boto3.client(
            "bedrock-runtime",
            region_name="eu-south-1"
        )
        self.model_id = "eu.amazon.nova-pro-v1:0"

    def process_prompt(self, chat: Chat, prompt: str, response_mode: str) -> str:
        try:
            response = self.client.converse(
                modelId=self.model_id,
                messages=[
                    {
                        "role": "user",
                        "content": [
                            {
                                "text": prompt
                            }
                        ]
                    }
                ],
                inferenceConfig={
                    "maxTokens": 512,
                    "temperature": 0.5,
                    "topP": 0.9
                }
            )

            return response["output"]["message"]["content"][0]["text"]

        except Exception as e:
            raise RuntimeError(
                f"Errore durante invocazione Bedrock '{self.model_id}': {str(e)}"
            )