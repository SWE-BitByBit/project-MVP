import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:command_it/command_it.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/home/view_model/home_view_model.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/dead_man/dead_man_settings.dart';

import '../../../../testing/mocks/dead_man/mock_dead_man_repository.dart';

class FakeDeadManSettings extends Fake implements DeadManSettings {
  @override
  final bool isActive;
  FakeDeadManSettings({required this.isActive});
}

void main() {
  late HomeViewModel viewModel;
  late MockDeadManRepository mockDeadManRepository;

  setUp(() {
    Command.globalExceptionHandler = (error, stackTrace) {};
    mockDeadManRepository = MockDeadManRepository();

    // Setup di default per il costruttore che chiama loadDashboard.run()
    when(() => mockDeadManRepository.currentSettings).thenReturn(null);
  });

  Future<void> initViewModel() async {
    viewModel = HomeViewModel(mockDeadManRepository);
  }

  group('HomeViewModel - Dashboard Items', () {
    test('loadDashboard dovrebbe restituire esattamente 3 elementi al termine', () async {
      await initViewModel();

      expect(viewModel.loadDashboard.value, isNotNull);
      expect(viewModel.loadDashboard.value.length, 3);

      final titles = viewModel.loadDashboard.value.map((e) => e.title).toList();
      expect(titles, containsAll([
        'Contatti Fidati',
        'Informazioni',
        'Luoghi Sicuri'
      ]));
    });

    test('Stato iniziale del comando dovrebbe essere popolato con gli elementi del dashboard', () {
      viewModel = HomeViewModel(mockDeadManRepository);
      expect(viewModel.loadDashboard.value, isNotEmpty);
      expect(viewModel.loadDashboard.value.length, 3);
    });
  });

  group('HomeViewModel - Dead Man Switch Status', () {
    test('isDeadManActive dovrebbe essere true se il repository ha impostazioni attive', () async {
      when(() => mockDeadManRepository.currentSettings)
          .thenReturn(FakeDeadManSettings(isActive: true));

      await initViewModel();

      expect(viewModel.isDeadManActive, isTrue);
      verify(() => mockDeadManRepository.currentSettings).called(1);
    });

    test('isDeadManActive dovrebbe essere false se il repository ha impostazioni disattive', () async {
      when(() => mockDeadManRepository.currentSettings)
          .thenReturn(FakeDeadManSettings(isActive: false));

      await initViewModel();

      expect(viewModel.isDeadManActive, isFalse);
    });

    test('isDeadManActive dovrebbe essere false se le impostazioni sono null', () async {
      when(() => mockDeadManRepository.currentSettings).thenReturn(null);

      await initViewModel();

      expect(viewModel.isDeadManActive, isFalse);
    });
  });
}