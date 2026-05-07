import sys
import os

src_path = os.path.abspath(os.path.join(os.path.dirname(__file__), "../../../src/safe_places"))
backend_path = os.path.abspath(os.path.join(os.path.dirname(__file__), "../../.."))
sys.path.insert(0, os.path.abspath(os.path.dirname(__file__)))
import conftest
sys.modules['conftest'] = conftest

sys.path.insert(1, src_path)
sys.path.insert(2, backend_path)

modules_to_clean = ["ports", "controller", "repository", "models", "service", "services", "domain", "adapters", "commands"]
for mod in list(sys.modules.keys()):
    if any(mod == clean_mod or mod.startswith(clean_mod + ".") for clean_mod in modules_to_clean):
        del sys.modules[mod]
        import importlib
        importlib.invalidate_caches()
