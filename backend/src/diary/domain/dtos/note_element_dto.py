from dataclasses import dataclass

@dataclass
class NoteElementDTO:
    note_id: str
    note_element_id: str
    type: str
    content: str

    def to_dict(self):
        return {
            "note_id": self.note_id,
            "note_element_id": self.note_element_id,
            "type": self.type,
            "content": self.content,
        }
    
    @staticmethod
    def from_domain(note_element):
        return NoteElementDTO(
            note_id=note_element.note_id,
            note_element_id=note_element.note_element_id,
            type=note_element.type,
            content=note_element.content
        )