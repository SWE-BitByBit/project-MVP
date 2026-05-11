from enum import Enum

class DiaryType(str, Enum):
    REAL_DIARY = "real_diary"
    FAKE_DIARY = "fake_diary"