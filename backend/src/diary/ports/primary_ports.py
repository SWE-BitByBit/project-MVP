from abc import ABC, abstractmethod
from typing import List
from domain.note import Note

class GetNotePort(ABC):
    @abstractmethod
    def get_note(self, cmd): pass

    @abstractmethod
    def list_notes(self, cmd) -> List[Note]: pass


class SetNotePort(ABC):
    @abstractmethod
    def add_note(self, cmd): pass


class DeleteNotePort(ABC):
    @abstractmethod
    def delete_note(self, cmd): pass