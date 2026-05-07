import os
import sys
import subprocess

def pytest_cmdline_main(config):
    os.environ.setdefault("AWS_DEFAULT_REGION", "eu-south-1")
    os.environ.setdefault("TABLE_CHATS", "chats_mvp")
    os.environ.setdefault("TABLE_MESSAGES", "chats_messages_mvp")