import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/locator.dart';
import '../../../../domain/models/diary/diary_session.dart';
import '../../../../domain/models/diary/diary_enums.dart';
import '../view_model/diary_view_model.dart';
import '../view_model/diary_access_view_model.dart';
import 'diary_access_screen.dart';
import 'diary_security_menu_widget.dart';
import 'note_actions_widget.dart';
import 'note_list_widget.dart';

/// Inietta il DiaryViewModel e mostra il [DiaryStateSwitcher] che decide se mostrare il login o le note.
class DiaryScreen extends StatelessWidget {
  const DiaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
    create: (_) => getIt<DiaryViewModel>(),
    child: const DiaryStateSwitcher(),
    );
  }
}

/// SWITCHER: Decide se mostrare il login del diario o le note, SENZA usare il Navigator.
class DiaryStateSwitcher extends StatelessWidget {
  const DiaryStateSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DiaryAccessViewModel>(
      builder: (context, accessVm, child) {
        if (accessVm.isCheckingStatus) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (accessVm.isAuthenticated) {
          return const DiaryScreenView();
        } else {
          return const DiaryAccessScreenView();
        }
      },
    );
  }
}

/// Ascolta gli eventi per gli errori e carica i dati iniziali.
class DiaryScreenView extends StatefulWidget {
  const DiaryScreenView({super.key});

  @override
  State<DiaryScreenView> createState() => _DiaryScreenViewState();
}

class _DiaryScreenViewState extends State<DiaryScreenView> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<DiaryViewModel>();
      final session = DiarySession.session;

      // Ascolto errori (come nel Chatbot)
      vm.asyncError.addListener(() {
        if (vm.asyncError.value != null) {
          _showFloatingSnackBar(vm.asyncError.value!);
          vm.asyncError.value = null; // Resetta l'errore dopo averlo mostrato
        }
      });

      // Carica le note automaticamente all'apertura del tab
      if (session.loggedDiary != null) {
        vm.loadNotes.run(session.loggedDiary!);
      }
    });
  }

  void _showFloatingSnackBar(String message) {
    final colorScheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: colorScheme.onError)),
        backgroundColor: colorScheme.error,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 80.0, left: 16.0, right: 16.0),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = DiarySession.session;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Diario'),
        centerTitle: true,
        backgroundColor: Colors.teal.shade200,
        actions: [
          IconButton(
            icon: const Icon(Icons.lock_outline),
            tooltip: 'Blocca Diario',
            onPressed: () {
              context.read<DiaryAccessViewModel>().logout.run();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Bottone per impostare la password del diario fittizio (visibile solo nel diario reale)
          if (session.loggedDiary == DiaryType.real_diary) ...[
            const SizedBox(height: 16),
            const DiarySecurityMenuWidget(),
            const SizedBox(height: 8),
          ],

          // Lista delle Note
          const Expanded(child: NoteListWidget()),
        ],
      ),
      floatingActionButton: const NoteActionsWidget(),
    );
  }
}