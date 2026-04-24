import json
from typing import Final, List

import boto3

from safe_places.models.marker import Marker
from safe_places.ports.safe_places_repository_port import SafePlacesRepositoryPort


class S3SafePlacesRepository(SafePlacesRepositoryPort):
    """
    Repository che recupera i marker dei luoghi sicuri da un bucket S3.

    :param bucket_name: Nome del bucket S3.
    :param file_key: Chiave del file JSON nel bucket.
    """

    def __init__(self, bucket_name: str, file_key: str) -> None:
        self._s3 = boto3.client("s3")
        self._bucket_name: Final[str] = bucket_name
        self._file_key: Final[str] = file_key

    def list_markers(self) -> List[Marker]:
        """
        Legge il file JSON da S3 e lo deserializza in una lista di Marker.

        :return: Lista di oggetti Marker.
        :raises Exception: Se il file non è raggiungibile o malformato.
        """
        response = self._s3.get_object(Bucket=self._bucket_name, Key=self._file_key)
        raw_content = response["Body"].read().decode("utf-8")
        items = json.loads(raw_content)

        return [
            Marker(
                marker_id=item["marker_id"],
                name=item["name"],
                address=item["address"],
                latitude=item["latitude"],
                longitude=item["longitude"],
                category=item["category"],
            )
            for item in items
        ]