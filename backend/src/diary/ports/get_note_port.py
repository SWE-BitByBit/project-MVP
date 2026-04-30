from abc import ABC, abstractmethod
from typing import List, Optional

from commands.get_note_command import GetNoteCmd
from commands.get_notes_command import GetNotesCmd
from domain.note import Note

class GetNotePort(ABC):
    @abstractmethod
    def get_note(self, cmd: GetNoteCmd) -> Optional[Note]:
        pass

    @abstractmethod
    def list_notes(self, cmd: GetNotesCmd) -> List[Note]: 
        pass