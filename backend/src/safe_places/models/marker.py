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
        latitude: float,
        longitude: float,
        category: str,
    ) -> None:
        self._marker_id: Final[str] = marker_id
        self._name: Final[str] = name
        self._address: Final[str] = address

        if not (-90.0 <= latitude <= 90.0):
            raise ValueError("La latitudine deve essere compresa tra -90 e 90 gradi.")
        if not (-180.0 <= longitude <= 180.0):
            raise ValueError("La longitudine deve essere compresa tra -180 e 180 gradi.")

        self._latitude: Final[float] = latitude
        self._longitude: Final[float] = longitude
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