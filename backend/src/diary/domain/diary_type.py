from enum import Enum

class DiaryType(str, Enum):
    REAL_DIARY = "REAL_DIARY"
    FAKE_DIARY = "FAKE_DIARY"