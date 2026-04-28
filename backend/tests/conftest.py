import sys
from pathlib import Path

# Aggiunge src/ al path per risolvere gli import con prefisso 'from src.<funzionalità>.xxx'
# usati nei file di test (es. from src.chatbot.services.xxx import ...).
# Gli import interni ai moduli Lambda (es. 'from ports.xxx import') sono gestiti
# tramite PYTHONPATH impostato nel Makefile e nella pipeline CI, che aggiunge
# src/<funzionalità>/ per ogni Lambda, replicando il comportamento di SAM a runtime.
src_path = Path(__file__).parent.parent / "src"
sys.path.insert(0, str(src_path))
