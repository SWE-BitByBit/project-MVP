import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:command_it/command_it.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/settings/view_model/dead_man_view_model.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/dead_man/dead_man_settings.dart';

import '../../../../testing/mocks/auth/mock_auth_repository.dart';
import '../../../../testing/mocks/dead_man/mock_dead_man_repository.dart';

class FakeDeadManSettings extends Fake implements DeadManSettings {
  @override
  final bool isActive;
  @override
  final int firstInactivityTimer;
  @override
  final int secondInactivityTimer;
  @override
  final String messageSubject;
  @override
  final String messageBody;

  FakeDeadManSettings({
    this.isActive = false,
    this.firstInactivityTimer = 30,
    this.secondInactivityTimer = 10,
    this.messageSubject = "Soggetto",
    this.messageBody = "Corpo",
  });

  @override
  DeadManSettings copyWith({
    bool? isActive,
    int? firstInactivityTimer,
    int? secondInactivityTimer,
    String? messageSubject,
    String? messageBody,
  }) {
    return FakeDeadManSettings(
      isActive: isActive ?? this.isActive,
      firstInactivityTimer: firstInactivityTimer ?? this.firstInactivityTimer,
      secondInactivityTimer: secondInactivityTimer ?? this.secondInactivityTimer,
      messageSubject: messageSubject ?? this.messageSubject,
      messageBody: messageBody ?? this.messageBody,
    );
  }
}

void main() {
  late DeadManViewModel viewModel;
  late MockDeadManRepository mockRepo;
  late MockAuthRepository mockAuthRepo;

  final initialSettings = FakeDeadManSettings(
    isActive: true,
    firstInactivityTimer: 60,
    secondInactivityTimer: 15,
    messageSubject: "Aiuto",
    messageBody: "Sono in pericolo",
  );

  setUpAll(() {
    registerFallbackValue(FakeDeadManSettings());
  });

  setUp(() {
    Command.globalExceptionHandler = (error, stackTrace) {};
    mockRepo = MockDeadManRepository();
    mockAuthRepo = MockAuthRepository();

    when(() => mockRepo.getSettings(forceRefresh: any(named: 'forceRefresh')))
        .thenAnswer((_) async => initialSettings);
    when(() => mockRepo.currentSettings).thenReturn(initialSettings);
    when(() => mockRepo.saveSettings(any())).thenAnswer((_) async => {});
  });

  Future<void> initViewModel() async {
    viewModel = DeadManViewModel(mockRepo, authRepository: mockAuthRepo);
    await viewModel.loadSettings.runAsync();
  }

  group('DeadManViewModel - Inizializzazione', () {
    test('Al caricamento popola draftSettings con una copia dei dati ufficiali', () async {
      await initViewModel();

      expect(viewModel.draftSettings, isNotNull);
      expect(viewModel.draftSettings!.isActive, initialSettings.isActive);
      expect(viewModel.hasUnsavedChanges, isFalse);
    });
  });

  group('DeadManViewModel - Gestione Draft (Bozza)', () {
    test('toggleActiveStatus aggiorna la bozza e notifica la UI', () async {
      await initViewModel();
      bool notified = false;
      viewModel.addListener(() => notified = true);

      viewModel.toggleActiveStatus(false);

      expect(viewModel.draftSettings!.isActive, isFalse);
      expect(viewModel.hasUnsavedChanges, isTrue);
      expect(notified, isTrue);
    });

    test('updateTimers aggiorna solo i campi specificati', () async {
      await initViewModel();

      viewModel.updateTimers(firstTimer: 120);

      expect(viewModel.draftSettings!.firstInactivityTimer, 120);
      expect(viewModel.draftSettings!.secondInactivityTimer, initialSettings.secondInactivityTimer);
      expect(viewModel.hasUnsavedChanges, isTrue);
    });

    test('updateMessage aggiorna i testi del messaggio', () async {
      await initViewModel();

      viewModel.updateMessage("Nuovo Soggetto", "Nuovo Corpo");

      expect(viewModel.draftSettings!.messageSubject, "Nuovo Soggetto");
      expect(viewModel.draftSettings!.messageBody, "Nuovo Corpo");
      expect(viewModel.hasUnsavedChanges, isTrue);
    });

    test('discardChanges ripristina la bozza ai valori del repository', () async {
      await initViewModel();
      viewModel.toggleActiveStatus(false);
      expect(viewModel.hasUnsavedChanges, isTrue);

      viewModel.discardChanges();

      expect(viewModel.draftSettings!.isActive, initialSettings.isActive);
      expect(viewModel.hasUnsavedChanges, isFalse);
    });
  });

  group('DeadManViewModel - Salvataggio', () {
    test('saveSettings chiama il repository e aggiorna la bozza con i nuovi dati salvati', () async {
      await initViewModel();
      viewModel.updateTimers(firstTimer: 99);

      final updatedSettings = viewModel.draftSettings!;

      when(() => mockRepo.saveSettings(any())).thenAnswer((_) async => {});
      when(() => mockRepo.currentSettings).thenReturn(updatedSettings);

      await viewModel.saveSettings.runAsync();

      verify(() => mockRepo.saveSettings(any())).called(1);
      expect(viewModel.hasUnsavedChanges, isFalse);
    });

    test('saveSettings non fa nulla se draftSettings è null (caricamento non completato)', () async {
      // Usiamo un Completer per "bloccare" il getSettings ed evitare che la bozza venga popolata
      final completer = Completer<DeadManSettings>();
      when(() => mockRepo.getSettings(forceRefresh: any(named: 'forceRefresh')))
          .thenAnswer((_) => completer.future);

      viewModel = DeadManViewModel(mockRepo, authRepository: mockAuthRepo);

      // draftSettings sarà null perché il completer non è ancora risolto
      expect(viewModel.draftSettings, isNull);

      await viewModel.saveSettings.runAsync();

      // Verifichiamo che non sia mai stato chiamato saveSettings sul repo
      verifyNever(() => mockRepo.saveSettings(any()));
    });
  });
}