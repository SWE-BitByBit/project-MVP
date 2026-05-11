import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:geolocator/geolocator.dart';
import 'package:command_it/command_it.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/safeplace/view_model/safe_place_view_model.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/safeplace/safe_place.dart';

import '../../../../testing/mocks/safeplace/mock_safe_place_repository.dart';
import '../../../../testing/mocks/safeplace/mock_location_service.dart';

class FakePosition extends Fake implements Position {
  @override
  final double latitude;
  @override
  final double longitude;

  FakePosition({this.latitude = 0.0, this.longitude = 0.0});
}

class FakeSafePlace extends Fake implements SafePlace {
  @override
  final String id;
  FakeSafePlace({required this.id});
}

void main() {
  late SafePlaceViewModel viewModel;
  late MockSafePlaceRepository mockRepo;
  late MockLocationService mockLocationService;

  setUp(() {
    Command.globalExceptionHandler = (error, stackTrace) {};
    mockRepo = MockSafePlaceRepository();
    mockLocationService = MockLocationService();

    // Comportamenti di default per permettere l'inizializzazione del costruttore
    when(() => mockRepo.getPlaces()).thenAnswer((_) async {return [];});
    when(() => mockRepo.cachedPlaces).thenReturn([]);
    when(() => mockLocationService.isLocationServiceEnabled()).thenAnswer((_) async => true);
    when(() => mockLocationService.checkPermission()).thenAnswer((_) async => LocationPermission.always);
    when(() => mockLocationService.getCurrentPosition()).thenAnswer((_) async => FakePosition());
  });

  /// Inizializza il ViewModel e attende il completamento dei comandi lanciati nel costruttore (.run())
  Future<void> initViewModel() async {
    viewModel = SafePlaceViewModel(mockRepo, locationService: mockLocationService);

    // Attendiamo che le esecuzioni avviate dal costruttore terminino
    // Usiamo runAsync() senza parametri per "agganciarci" all'esecuzione in corso o avviarne una se terminata
    await viewModel.loadPlaces.runAsync();
    await viewModel.getUserLocation.runAsync();
  }

  group('SafePlaceViewModel - Initialization & Loading', () {
    test('Costruttore dovrebbe avviare il caricamento dei luoghi e della posizione', () async {
      await initViewModel();

      // Verifichiamo che siano stati chiamati (almeno una volta dal costruttore)
      verify(() => mockRepo.getPlaces()).called(greaterThanOrEqualTo(1));
      verify(() => mockLocationService.getCurrentPosition()).called(greaterThanOrEqualTo(1));
      expect(viewModel.safePlaces, isEmpty);
    });

    test('loadPlaces aggiorna lo stato tramite il repository', () async {
      final places = [FakeSafePlace(id: '1'), FakeSafePlace(id: '2')];
      when(() => mockRepo.cachedPlaces).thenReturn(places);

      await initViewModel();
      // Rieseguiamo per sicurezza
      await viewModel.loadPlaces.runAsync();

      expect(viewModel.safePlaces.length, 2);
      expect(viewModel.safePlaces, places);
    });
  });

  group('SafePlaceViewModel - Location Logic', () {
    test('getUserLocation salva la posizione se i permessi sono validi', () async {
      final pos = FakePosition(latitude: 45.0, longitude: 9.0);
      when(() => mockLocationService.getCurrentPosition()).thenAnswer((_) async => pos);

      await initViewModel();
      await viewModel.getUserLocation.runAsync();

      expect(viewModel.userPosition, pos);
      expect(viewModel.userPosition?.latitude, 45.0);
    });

    test('getUserLocation solleva eccezione se il GPS è spento', () async {
      when(() => mockLocationService.isLocationServiceEnabled()).thenAnswer((_) async => false);

      // Inizializzazione manuale per catturare l'errore del comando
      viewModel = SafePlaceViewModel(mockRepo, locationService: mockLocationService);

      // Il comando lanciato nel costruttore fallirà, lo rieseguiamo per testare l'eccezione
      expect(
            () => viewModel.getUserLocation.runAsync(),
        throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains('disabilitati'))),
      );
    });

    test('getUserLocation richiede i permessi se negati inizialmente', () async {
      when(() => mockLocationService.checkPermission()).thenAnswer((_) async => LocationPermission.denied);
      when(() => mockLocationService.requestPermission()).thenAnswer((_) async => LocationPermission.whileInUse);

      await initViewModel();
      await viewModel.getUserLocation.runAsync();

      verify(() => mockLocationService.requestPermission()).called(greaterThanOrEqualTo(1));
      expect(viewModel.userPosition, isNotNull);
    });

    test('getUserLocation fallisce se i permessi sono negati permanentemente', () async {
      when(() => mockLocationService.checkPermission()).thenAnswer((_) async => LocationPermission.deniedForever);

      viewModel = SafePlaceViewModel(mockRepo, locationService: mockLocationService);

      expect(
            () => viewModel.getUserLocation.runAsync(),
        throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains('permanentemente'))),
      );
    });
  });

  group('SafePlaceViewModel - UI Actions', () {
    test('selectPlace aggiorna correttamente il luogo selezionato', () async {
      await initViewModel();
      final place = FakeSafePlace(id: 'target');

      bool notified = false;
      viewModel.addListener(() => notified = true);

      viewModel.selectPlace(place);

      expect(viewModel.selectedPlace, place);
      expect(notified, isTrue);
    });

    test('saveMapSessionState aggiorna la cache del repository senza notificare la UI', () async {
      await initViewModel();

      bool notified = false;
      viewModel.addListener(() => notified = true);

      viewModel.saveMapSessionState(10.0, 20.0, 15.0);

      verify(() => mockRepo.cachedMapState = (latitude: 10.0, longitude: 20.0, zoom: 15.0)).called(1);
      expect(notified, isFalse);
    });
  });
}