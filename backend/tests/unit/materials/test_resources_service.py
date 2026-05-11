import json
from typing import List
from unittest.mock import MagicMock

import pytest

from materials.models.resource import Resource
from materials.models.resource_type import ResourceType
from materials.service.resources_service import ResourcesService


def _crea_risorsa(
    resource_id: str = "res-001",
    title: str = "Titolo",
    content: str = "Contenuto",
    url: str = "https://example.com",
    resource_type: ResourceType = ResourceType.ARTICLE,
) -> Resource:
    """Helper per costruire un oggetto Resource di test."""
    return Resource(
        resource_id=resource_id,
        title=title,
        content=content,
        url=url,
        resource_type=resource_type,
    )


class TestResourcesService:
    """Test per la classe ResourcesService."""

    def test_get_resources_delega_al_repository(self):
        """Verifica che get_resources invochi list_all_resources sul repository."""
        mock_repository = MagicMock()
        mock_repository.list_all_resources.return_value = []
        service = ResourcesService(mock_repository)

        service.get_resources()

        mock_repository.list_all_resources.assert_called_once()

    def test_get_resources_restituisce_lista_vuota(self):
        """Verifica che get_resources restituisca una lista vuota se il repository è vuoto."""
        mock_repository = MagicMock()
        mock_repository.list_all_resources.return_value = []
        service = ResourcesService(mock_repository)

        result = service.get_resources()

        assert result == []

    def test_get_resources_restituisce_risorse(self):
        """Verifica che get_resources restituisca le risorse del repository."""
        risorsa = _crea_risorsa()
        mock_repository = MagicMock()
        mock_repository.list_all_resources.return_value = [risorsa]
        service = ResourcesService(mock_repository)

        result = service.get_resources()

        assert len(result) == 1
        assert result[0] is risorsa

    def test_get_resources_propaga_eccezione_del_repository(self):
        """Verifica che get_resources propaghi le eccezioni sollevate dal repository."""
        mock_repository = MagicMock()
        mock_repository.list_all_resources.side_effect = RuntimeError("Errore S3")
        service = ResourcesService(mock_repository)

        with pytest.raises(RuntimeError, match="Errore S3"):
            service.get_resources()

    def test_get_resources_restituisce_lista_multipla(self):
        """Verifica che get_resources restituisca correttamente più risorse."""
        risorse: List[Resource] = [
            _crea_risorsa(resource_id="r1", resource_type=ResourceType.ARTICLE),
            _crea_risorsa(resource_id="r2", resource_type=ResourceType.LAW),
            _crea_risorsa(resource_id="r3", resource_type=ResourceType.COMMUNITY),
        ]
        mock_repository = MagicMock()
        mock_repository.list_all_resources.return_value = risorse
        service = ResourcesService(mock_repository)

        result = service.get_resources()

        assert len(result) == 3
