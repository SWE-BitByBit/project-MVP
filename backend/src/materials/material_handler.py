import json
from typing import Any, Dict, Final
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


class MaterialHandler:
    """
    Classe che gestisce la richiesta per il recupero dei materiali informativi.
    """

    def __init__(self, s3_client: S3Client) -> None:
        """
        Inizializza l'handler con un istanza di S3Client.

        :param s3_client: Client per l'accesso ai dati su S3.
        """
        self._s3_client = s3_client

    def handle(self) -> Dict[str, Any]:
        """
        Coordina il recupero del file e la generazione della risposta API.

        :return: Dizionario contenente statusCode, headers e body per API Gateway.
        """
        # Costanti definite come Final per rispettare i vincoli di immutabilità
        BUCKET_NAME: Final[str] = 'app-protegge-trasforma-materials-mvp'
        FILE_KEY: Final[str] = 'materials.json'

        try:
            # Recupero dei dati tramite il client S3
            raw_content = self._s3_client.get_object_content(BUCKET_NAME, FILE_KEY)
            parsed_data = json.loads(raw_content)

            # Risposta di successo
            return {
                'statusCode': 200,
                'headers': {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*'
                },
                'body': json.dumps(parsed_data)
            }

        except Exception as error:
            # Gestione dell'errore e risposta 500
            return {
                'statusCode': 500,
                'headers': {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*'
                },
                'body': json.dumps({'errorMessage': str(error)})
            }


def lambda_handler(event: Dict[str, Any], context: Any) -> Dict[str, Any]:
    """
    Punto di ingresso della funzione Lambda di AWS.

    :param event: Evento scatenante fornito da AWS.
    :param context: Contesto di esecuzione della Lambda.
    :return: Risposta formattata per l'integrazione proxy di API Gateway.
    """
    # Nessuno stato globale: istanzio i componenti ad ogni invocazione
    s3_client = S3Client()
    handler = MaterialHandler(s3_client)
    
    return handler.handle()