import re

with open("tests/integration/chatbot/conftest.py", "r", encoding="utf-8") as f:
    content = f.read()

content = content.replace('os.environ["TABLE_CHATS"] = "chats_mvp"\n', "")
content = content.replace('os.environ["TABLE_MESSAGES"] = "chats_messages_mvp"\n', "")
content = content.replace('os.environ["AWS_DEFAULT_REGION"] = "eu-south-1"', """@pytest.fixture(autouse=True)
def setup_env_vars(monkeypatch):
    monkeypatch.setenv("TABLE_CHATS", "chats_mvp")
    monkeypatch.setenv("TABLE_MESSAGES", "chats_messages_mvp")
    monkeypatch.setenv("AWS_DEFAULT_REGION", "eu-south-1")""")

with open("tests/integration/chatbot/conftest.py", "w", encoding="utf-8") as f:
    f.write(content)
