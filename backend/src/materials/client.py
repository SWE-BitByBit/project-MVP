from typing import Any, Dict
from botocore.config import Config
import boto3

class S3Client:
    """
    Classe che incapsula la comunicazione con il servizio AWS S3.
    """

    def __init__(self) -> None:
        """
        Inizializza il client S3 specificando un timeout esplicito.
        """
        config = Config(connect_timeout=5, read_timeout=5)
        self._s3 = boto3.client('s3', config=config)

    def get_object_content(self, bucket: str, key: str) -> str:
        """
        Recupera il contenuto di un oggetto da un bucket S3.

        :param bucket: Nome del bucket S3.
        :param key: Chiave del file all'interno del bucket.
        :return: Contenuto del file decodificato in UTF-8.
        """
        response = self._s3.get_object(Bucket=bucket, Key=key)
        return response['Body'].read().decode('utf-8')
