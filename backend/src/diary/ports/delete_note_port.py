from abc import ABC, abstractmethod

from commands.delete_note_command import DeleteNoteCmd

class DeleteNotePort(ABC):
    
    @abstractmethod
    def delete_note(self, cmd: DeleteNoteCmd) -> bool:
        pass