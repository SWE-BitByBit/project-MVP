import pytest

from src.safe_places.models.marker import Marker


class TestMarker:
    """Test per il modello Marker."""

    def _make_marker(
        self,
        marker_id: str = "luogo-001",
        name: str = "Ospedale Test",
        address: str = "Via Test 1",
        latitude: float = 45.0,
        longitude: float = 11.0,
        category: str = "ospedale",
    ) -> Marker:
        """Helper per creare un marker con valori di default."""
        return Marker(
            marker_id=marker_id,
            name=name,
            address=address,
            latitude=latitude,
            longitude=longitude,
            category=category,
        )

    def test_to_dict_contiene_marker_id(self):
        """Verifica che to_dict includa il campo marker_id."""
        marker = self._make_marker(marker_id="id-123")
        result = marker.to_dict()
        assert result["marker_id"] == "id-123"

    def test_to_dict_contiene_name(self):
        """Verifica che to_dict includa il campo name."""
        marker = self._make_marker(name="Centro Sicuro")
        result = marker.to_dict()
        assert result["name"] == "Centro Sicuro"

    def test_to_dict_contiene_address(self):
        """Verifica che to_dict includa il campo address."""
        marker = self._make_marker(address="Via Roma")
        result = marker.to_dict()
        assert result["address"] == "Via Roma"

    def test_to_dict_contiene_latitude(self):
        """Verifica che to_dict includa il campo latitude."""
        marker = self._make_marker(latitude=45.123)
        result = marker.to_dict()
        assert result["latitude"] == 45.123

    def test_to_dict_contiene_longitude(self):
        """Verifica che to_dict includa il campo longitude."""
        marker = self._make_marker(longitude=11.456)
        result = marker.to_dict()
        assert result["longitude"] == 11.456

    def test_to_dict_contiene_category(self):
        """Verifica che to_dict includa il campo category."""
        marker = self._make_marker(category="polizia")
        result = marker.to_dict()
        assert result["category"] == "polizia"

    def test_to_dict_restituisce_dizionario(self):
        """Verifica che to_dict restituisca un oggetto di tipo dict."""
        marker = self._make_marker()
        assert isinstance(marker.to_dict(), dict)

    def test_to_dict_numero_campi(self):
        """Verifica che to_dict contenga esattamente 6 campi."""
        marker = self._make_marker()
        assert len(marker.to_dict()) == 6

    def test_invalid_latitude_raises_error(self):
        """Verifica che una latitudine non valida sollevi ValueError."""
        with pytest.raises(ValueError, match="La latitudine deve essere compresa tra -90 e 90 gradi."):
            self._make_marker(latitude=90.1)
        with pytest.raises(ValueError, match="La latitudine deve essere compresa tra -90 e 90 gradi."):
            self._make_marker(latitude=-90.1)

    def test_invalid_longitude_raises_error(self):
        """Verifica che una longitudine non valida sollevi ValueError."""
        with pytest.raises(ValueError, match="La longitudine deve essere compresa tra -180 e 180 gradi."):
            self._make_marker(longitude=180.1)
        with pytest.raises(ValueError, match="La longitudine deve essere compresa tra -180 e 180 gradi."):
            self._make_marker(longitude=-180.1)
