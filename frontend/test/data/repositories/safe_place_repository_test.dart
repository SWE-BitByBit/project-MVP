import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mvp_app_protegge_e_trasforma/data/repositories/safe_place_repository.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/safeplace/safe_place.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/safeplace/safe_place_enums.dart';

import '../../../testing/mocks/safeplace/mock_safe_place_service.dart';

void main() {
  late MockSafePlaceService mockService;
  late SafePlaceRepository repository;

  setUp(() {
    mockService = MockSafePlaceService();
    repository = SafePlaceRepository(mockService);
  });

  final mockApiResponse = {
    'data': [
      {
        'marker_id': 'sp_1',
        'name': 'Ospedale Niguarda',
        'address': 'Piazza Ospedale Maggiore, 3',
        'latitude': 45.505,
        'longitude': 9.188,
        'category': 'ospedale'
      },
      {
        'marker_id': 'sp_2',
        'name': 'Commissariato Centro',
        'address': 'Via Croce Rossa, 5',
        'latitude': 45.471,
        'longitude': 9.193,
        'category': 'polizia'
      }
    ]
  };

  group('SafePlaceRepository Tests', () {
    test('cachedPlaces dovrebbe essere inizialmente vuoto', () {
      expect(repository.cachedPlaces, isEmpty);
      expect(repository.cachedMapState, isNull);
    });

    group('getPlaces', () {
      test('dovrebbe scaricare dati dal service, popolare la cache e restituire la lista (Happy Path)', () async {
        // Arrange
        when(() => mockService.fetchSafePlaces()).thenAnswer((_) async => mockApiResponse);

        // Act
        final results = await repository.getPlaces();

        // Assert
        expect(results.length, 2);
        expect(results[0].id, 'sp_1');
        expect(results[1].name, 'Commissariato Centro');
        expect(repository.cachedPlaces.length, 2);
        verify(() => mockService.fetchSafePlaces()).called(1);
      });

      test('dovrebbe restituire i dati dalla cache senza chiamare il service se la cache non è vuota', () async {
        // Arrange
        when(() => mockService.fetchSafePlaces()).thenAnswer((_) async => mockApiResponse);
        await repository.getPlaces(); // Popola cache
        clearInteractions(mockService);

        // Act
        final results = await repository.getPlaces();

        // Assert
        expect(results.length, 2);
        verifyNever(() => mockService.fetchSafePlaces());
      });

      test('dovrebbe forzare il refresh se forceRefresh è true', () async {
        // Arrange
        when(() => mockService.fetchSafePlaces()).thenAnswer((_) async => mockApiResponse);
        await repository.getPlaces();

        clearInteractions(mockService);

        final updatedResponse = {
          'data': [
            {'marker_id': 'sp_new', 'name': 'Nuovo Luogo', 'latitude': 0.0, 'longitude': 0.0}
          ]
        };
        when(() => mockService.fetchSafePlaces()).thenAnswer((_) async => updatedResponse);

        // Act
        final results = await repository.getPlaces(forceRefresh: true);

        // Assert
        expect(results.length, 1);
        expect(results.first.id, 'sp_new');
        verify(() => mockService.fetchSafePlaces()).called(1);
      });
    });

    group('Map State Management', () {
      test('dovrebbe memorizzare e restituire correttamente lo stato della sessione mappa (Record)', () {
        // Arrange
        final MapSessionState newState = (latitude: 45.0, longitude: 9.0, zoom: 12.5);

        // Act
        repository.cachedMapState = newState;

        // Assert
        expect(repository.cachedMapState, isNotNull);
        expect(repository.cachedMapState?.latitude, 45.0);
        expect(repository.cachedMapState?.zoom, 12.5);
      });
    });

    group('clearCache', () {
      test('dovrebbe svuotare la lista dei luoghi e resettare lo stato della mappa', () async {
        // Arrange
        when(() => mockService.fetchSafePlaces()).thenAnswer((_) async => mockApiResponse);
        await repository.getPlaces();
        repository.cachedMapState = (latitude: 1.0, longitude: 1.0, zoom: 1.0);

        // Act
        repository.clearCache();

        // Assert
        expect(repository.cachedPlaces, isEmpty);
        expect(repository.cachedMapState, isNull);
      });
    });

    test('cachedPlaces dovrebbe essere immutabile dall\'esterno', () async {
      // Arrange
      when(() => mockService.fetchSafePlaces()).thenAnswer((_) async => mockApiResponse);
      await repository.getPlaces();

      // Act & Assert
      expect(
              () => (repository.cachedPlaces as dynamic).add(
              SafePlace(
                  id: '3',
                  name: 'X',
                  address: 'Y',
                  latitude: 0,
                  longitude: 0,
                  category: SafePlaceCategory.other
              )
          ),
          throwsUnsupportedError
      );
    });
  });
}
