import sys
from pathlib import Path

# Aggiunge la cartella 'src' al PYTHONPATH
src_path = str(Path(__file__).parent.parent / "src")
sys.path.insert(0, src_path)
print(f"✅ Added to PYTHONPATH: {src_path}")  # <-- aggiungi questa riga
print(f"PYTHONPATH now contains: {src_path in sys.path}")  # <-- e questa
