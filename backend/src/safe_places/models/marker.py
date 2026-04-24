from typing import Any, Dict, Final


class Marker:
    """
    Rappresenta un luogo sicuro sulla mappa.

    :param marker_id: Identificativo univoco del marker.
    :param name: Nome del luogo sicuro.
    :param address: Indirizzo del luogo sicuro.
    :param latitude: Latitudine del luogo.
    :param longitude: Longitudine del luogo.
    :param category: Categoria del luogo (es. "ospedale", "carabinieri").
    """

    def __init__(
        self,
        marker_id: str,
        name: str,
        address: str,
        latitude: str,
        longitude: str,
        category: str,
    ) -> None:
        self._marker_id: Final[str] = marker_id
        self._name: Final[str] = name
        self._address: Final[str] = address
        self._latitude: Final[str] = latitude
        self._longitude: Final[str] = longitude
        self._category: Final[str] = category

    def to_dict(self) -> Dict[str, Any]:
        """
        Serializza il marker in un dizionario JSON-compatibile.

        :return: Dizionario con i campi del marker.
        """
        return {
            "marker_id": self._marker_id,
            "name": self._name,
            "address": self._address,
            "latitude": self._latitude,
            "longitude": self._longitude,
            "category": self._category,
        }