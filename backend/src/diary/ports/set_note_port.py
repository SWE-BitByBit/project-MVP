from abc import ABC, abstractmethod

from commands.add_note_command import AddNoteCmd
from domain.note import Note

class SetNotePort(ABC):

    @abstractmethod
    def add_note(self, cmd: AddNoteCmd) -> Note: 
        pass