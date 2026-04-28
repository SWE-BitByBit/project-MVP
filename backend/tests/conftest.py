import sys
import os

BASE_DIR = os.path.dirname(os.path.dirname(__file__))

sys.path.insert(0, os.path.join(BASE_DIR, "src"))
sys.path.insert(0, os.path.join(BASE_DIR, "src/materials"))
sys.path.insert(0, os.path.join(BASE_DIR, "src/trusted_contact"))
sys.path.insert(0, os.path.join(BASE_DIR, "src/diary"))