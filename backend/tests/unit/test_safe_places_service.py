from unittest.mock import MagicMock

from src.safe_places.models.marker import Marker
from src.safe_places.service.safe_places_service import SafePlacesService


class TestSafePlacesService:
    """Test per la classe SafePlacesService."""

    def test_get_all_markers_delega_al_repository(self):
        """Verifica che il service deleghi correttamente la chiamata al repository."""
        mock_repository = MagicMock()
        mock_markers = [
            Marker("1", "N1", "A1", "45", "11", "C1"),
            Marker("2", "N2", "A2", "46", "12", "C2")
        ]
        mock_repository.list_markers.return_value = mock_markers
        
        service = SafePlacesService(repository=mock_repository)
        result = service.get_all_markers()
        
        assert result == mock_markers
        mock_repository.list_markers.assert_called_once()

    def test_get_all_markers_propaga_eccezione(self):
        """Verifica che le eccezioni lanciate dal repository vengano propagate."""
        mock_repository = MagicMock()
        mock_repository.list_markers.side_effect = Exception("Errore DB")
        
        service = SafePlacesService(repository=mock_repository)
        
        import pytest
        with pytest.raises(Exception) as excinfo:
            service.get_all_markers()
            
        assert "Errore DB" in str(excinfo.value)
