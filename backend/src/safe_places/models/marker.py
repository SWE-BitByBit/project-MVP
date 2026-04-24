from typing import Any, Dict, Final


class Marker:
    """
    Rappresenta un luogo sicuro sulla mappa.

    :param marker_id: Identificativo univoco del marker.
    :param latitude: Latitudine del luogo.
    :param longitude: Longitudine del luogo.
    """

    def __init__(
        self,
        marker_id: str,
        latitude: str,
        longitude: str,
    ) -> None:
        self._marker_id: Final[str] = marker_id
        self._latitude: Final[str] = latitude
        self._longitude: Final[str] = longitude

    def to_dict(self) -> Dict[str, Any]:
        """
        Serializza il marker in un dizionario JSON-compatibile.

        :return: Dizionario con i campi del marker.
        """
        return {
            "marker_id": self._marker_id,
            "latitude": self._latitude,
            "longitude": self._longitude,
        }