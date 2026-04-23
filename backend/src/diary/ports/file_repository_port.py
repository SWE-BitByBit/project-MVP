from abc import ABC, abstractmethod

class FileRepositoryPort(ABC):

    @abstractmethod
    def generate_presigned_upload(self, key: str) -> str: pass