# tests/unit/diary/conftest.py
import sys
import os

src_diary_path = os.path.abspath(os.path.join(os.path.dirname(__file__), "../../../src/diary"))
backend_path = os.path.abspath(os.path.join(os.path.dirname(__file__), "../../.."))

sys.path.insert(0, os.path.abspath(os.path.dirname(__file__)))
import conftest
sys.modules['diary_unit_conftest'] = conftest

sys.path.insert(1, src_diary_path)
sys.path.insert(2, backend_path)

# Cleanup di moduli comuni per evitare conflitti tra diversi test di integrazione/unità
modules_to_clean = ["ports", "controller", "repository", "models", "service", "services", "domain", "adapters", "commands", "diary_type", "note_element"]
for mod in list(sys.modules.keys()):
    if any(mod == clean_mod or mod.startswith(clean_mod + ".") for clean_mod in modules_to_clean):
        if mod in sys.modules: del sys.modules[mod]
        import importlib
        importlib.invalidate_caches()

import pytest
import boto3
from moto import mock_aws

@pytest.fixture(scope="function")
def setup_aws():
    with mock_aws():
        dynamodb = boto3.resource("dynamodb", region_name="us-east-1")
        yield {"dynamodb": dynamodb}
