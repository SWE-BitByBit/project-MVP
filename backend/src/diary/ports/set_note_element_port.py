from abc import ABC, abstractmethod

from commands.add_note_element_command import AddNoteElementCmd
from domain.note_element import NoteElement

class SetNoteElementPort(ABC):
    @abstractmethod
    def add_note_element(self, cmd: AddNoteElementCmd) -> NoteElement:
        pass