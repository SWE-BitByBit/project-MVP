from abc import ABC, abstractmethod
from typing import List, Optional

from domain.note import Note

class NoteRepositoryPort(ABC):

    @abstractmethod
    def add(self, note) -> Optional[Note]: 
        pass

    @abstractmethod
    def get(self, user_id, note_id, diary_type) -> Optional[Note]: 
        pass

    @abstractmethod
    def list(self, user_id, diary_type) -> Optional[List[Note]]: 
        pass
    
    @abstractmethod
    def delete(self, user_id, diary_type) -> None:
        pass