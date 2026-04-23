from abc import ABC, abstractmethod

class NoteRepositoryPort(ABC):

    @abstractmethod
    def add(self, note): pass

    @abstractmethod
    def get(self, user_id, note_id, diary_type): pass

    @abstractmethod
    def list(self, user_id, diary_type): pass