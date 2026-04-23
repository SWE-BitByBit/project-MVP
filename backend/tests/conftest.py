import sys
import os

# Aggiunge la directory 'src' al percorso di ricerca dei moduli Python.
# Questo è necessario perché i moduli Lambda utilizzano import relativi al package
# (es. 'from materials.xxx import ...') che devono essere risolti a partire da 'src/'.
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "src"))
