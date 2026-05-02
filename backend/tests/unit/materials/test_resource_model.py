import pytest

from materials.models.resource import Resource
from materials.models.resource_type import ResourceType


class TestResourceType:
    """Test per l'enumerazione ResourceType."""

    def test_valori_enum_community(self):
        """Verifica che il valore COMMUNITY sia corretto."""
        assert ResourceType.COMMUNITY.value == "COMMUNITY"

    def test_valori_enum_law(self):
        """Verifica che il valore LAW sia corretto."""
        assert ResourceType.LAW.value == "LAW"

    def test_valori_enum_article(self):
        """Verifica che il valore ARTICLE sia corretto."""
        assert ResourceType.ARTICLE.value == "ARTICLE"

    def test_costruzione_da_stringa(self):
        """Verifica che ResourceType si costruisca correttamente da stringa."""
        assert ResourceType("LAW") == ResourceType.LAW

    def test_costruzione_stringa_non_valida(self):
        """Verifica che una stringa non valida sollevi ValueError."""
        with pytest.raises(ValueError):
            ResourceType("INVALID")


class TestResource:
    """Test per il modello Resource."""

    def _make_resource(
        self,
        resource_id: str = "res-001",
        title: str = "Guida alla sicurezza",
        content: str = "Contenuto di esempio",
        url: str = "https://example.com/guida",
        resource_type: ResourceType = ResourceType.ARTICLE,
    ) -> Resource:
        """Helper per creare una risorsa con valori di default."""
        return Resource(
            resource_id=resource_id,
            title=title,
            content=content,
            url=url,
            resource_type=resource_type,
        )

    def test_to_dict_contiene_resource_id(self):
        """Verifica che to_dict includa il campo resource_id."""
        resource = self._make_resource(resource_id="abc-123")
        result = resource.to_dict()
        assert result["resource_id"] == "abc-123"

    def test_to_dict_contiene_title(self):
        """Verifica che to_dict includa il campo title."""
        resource = self._make_resource(title="Titolo Test")
        result = resource.to_dict()
        assert result["title"] == "Titolo Test"

    def test_to_dict_contiene_content(self):
        """Verifica che to_dict includa il campo content."""
        resource = self._make_resource(content="Corpo del testo")
        result = resource.to_dict()
        assert result["content"] == "Corpo del testo"

    def test_to_dict_contiene_url(self):
        """Verifica che to_dict includa il campo url."""
        resource = self._make_resource(url="https://example.com")
        result = resource.to_dict()
        assert result["url"] == "https://example.com"

    def test_to_dict_contiene_type_come_stringa(self):
        """Verifica che to_dict serializzi il tipo come valore stringa dell'enum."""
        resource = self._make_resource(resource_type=ResourceType.COMMUNITY)
        result = resource.to_dict()
        assert result["type"] == "COMMUNITY"

    def test_to_dict_con_tipo_law(self):
        """Verifica la serializzazione corretta del tipo LAW."""
        resource = self._make_resource(resource_type=ResourceType.LAW)
        result = resource.to_dict()
        assert result["type"] == "LAW"

    def test_to_dict_con_tipo_article(self):
        """Verifica la serializzazione corretta del tipo ARTICLE."""
        resource = self._make_resource(resource_type=ResourceType.ARTICLE)
        result = resource.to_dict()
        assert result["type"] == "ARTICLE"

    def test_to_dict_restituisce_dizionario(self):
        """Verifica che to_dict restituisca un oggetto di tipo dict."""
        resource = self._make_resource()
        assert isinstance(resource.to_dict(), dict)

    def test_to_dict_numero_campi(self):
        """Verifica che to_dict contenga esattamente 5 campi."""
        resource = self._make_resource()
        assert len(resource.to_dict()) == 5
