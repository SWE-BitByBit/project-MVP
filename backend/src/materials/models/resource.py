from typing import Any, Dict, Final

from materials.models.resource_type import ResourceType


class Resource:
    """
    Rappresenta un materiale informativo del sistema.

    :param resource_id: Identificativo univoco della risorsa.
    :param title: Titolo della risorsa.
    :param content: Contenuto testuale della risorsa.
    :param url: URL associato alla risorsa.
    :param resource_type: Tipo della risorsa (COMMUNITY, LAW, ARTICLE).
    """

    def __init__(
        self,
        resource_id: str,
        title: str,
        content: str,
        url: str,
        resource_type: ResourceType,
    ) -> None:
        self._resource_id: Final[str] = resource_id
        self._title: Final[str] = title
        self._content: Final[str] = content
        self._url: Final[str] = url
        self._type: Final[ResourceType] = resource_type

    def to_dict(self) -> Dict[str, Any]:
        """
        Serializza la risorsa in un dizionario JSON-compatibile.

        :return: Dizionario con i campi della risorsa.
        """
        return {
            "resource_id": self._resource_id,
            "title": self._title,
            "content": self._content,
            "url": self._url,
            "type": self._type.value,
        }