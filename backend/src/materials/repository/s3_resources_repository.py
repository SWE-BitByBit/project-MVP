import json
from typing import Final, List

import boto3

from models.resource import Resource
from models.resource_type import ResourceType
from ports.resources_repository_port import ResourcesRepositoryPort


class S3ResourcesRepository(ResourcesRepositoryPort):
    """
    Repository che recupera le risorse da un bucket S3.

    :param bucket_name: Nome del bucket S3.
    :param file_key: Chiave del file JSON nel bucket.
    """

    def __init__(self, bucket_name: str, file_key: str) -> None:
        self._s3 = boto3.client("s3")
        self._bucket_name: Final[str] = bucket_name
        self._file_key: Final[str] = file_key

    def list_all_resources(self) -> List[Resource]:
        """
        Legge il file JSON da S3 e lo deserializza in una lista di Resource.

        :return: Lista di oggetti Resource.
        :raises Exception: Se il file non è raggiungibile o malformato.
        """
        # Lettura del file JSON dal bucket S3
        response = self._s3.get_object(Bucket=self._bucket_name, Key=self._file_key)
        raw_content = response["Body"].read().decode("utf-8")
        items = json.loads(raw_content)

        # Conversione di ogni elemento nel modello Resource
        return [
            Resource(
                resource_id=item["resource_id"],
                title=item["title"],
                content=item["content"],
                url=item["url"],
                resource_type=ResourceType(item["type"]),
            )
            for item in items
        ]