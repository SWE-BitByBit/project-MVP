import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mvp_app_protegge_e_trasforma/data/repositories/diary_account_repository.dart';
import 'package:mvp_app_protegge_e_trasforma/data/repositories/note_repository.dart';
import 'package:mvp_app_protegge_e_trasforma/data/services/diary_account_service.dart';
import 'package:mvp_app_protegge_e_trasforma/data/services/note_service.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/diary_session.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/diary_type.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/diary/view_model/diary_viewmodel.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/diary/widget/diary_access_screen.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/diary/widget/diary_password_setting_widget.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/diary/widget/note_actions_widget.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/diary/widget/note_list_widget.dart';
import 'package:provider/provider.dart';

/// Pagina principale del diario.
///
/// Istanzia le dipendenze e poi fa dependency injection tramite [ChangeNotifierProvider]
/// Logica di stato e l'effettiva costruzione della UI sono delegate ai vari widget
class DiaryScreen extends StatelessWidget {
  const DiaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = DiarySession.session;
    //Se l'utente non ha effettuato l'accesso e in qualche modo arriva al diario, lo riporta alla schermata di login
    if (session.isDiaryAuth == null || session.isDiaryAuth == false) {
      Timer(
        const Duration(seconds: 1),
        () => Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const DiaryAccessScreen()),
          (route) => false,
        ),
      );
    }
    return ChangeNotifierProvider(
      create: (_) {
        final service = NoteService();
        final repository = NoteRepository(service);
        final accService = DiaryAccountService();
        final accRepository = DiaryAccountRepository(accService);
        final viewmodel = DiaryViewmodel(repository, accRepository);
        final diarySession = DiarySession.session;

        if (diarySession.isDiaryAuth != null) {
          viewmodel.loadPreviews(diarySession.loggedDiary!);
          viewmodel.sortNotes();
        }
        return viewmodel;
      },
      child: const DiaryScreenView(),
    );
  }
}

/// Vista pura
///
/// Riceve [DiaryViewmodel] dal provider e compone il layout con i widget [NoteListWidget] e [NoteActionsWidget]
/// per la visualizzazione a lista delle note e la gestione del pulsante per l'aggiunta di note rispettivamente
class DiaryScreenView extends StatelessWidget {
  const DiaryScreenView({super.key});
  @override
  Widget build(BuildContext context) {
    final session = DiarySession.session;
    return PopScope(
      ///Logout dal diario quando si esce dalla schermata.
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) DiarySession.session.endSession();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Diario'),
          centerTitle: true,
          backgroundColor: Colors.teal.shade200,
        ),
        body: Consumer<DiaryViewmodel>(
          builder: (context, viewModel, child) {
            return Column(
              children: [
                if (viewModel.error != null)
                  Container(
                    width: double.infinity,
                    color: Colors.red.shade50,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            viewModel.error!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (session.loggedDiary == DiaryType.realDiary) ...[
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      viewModel.resetFakePasswordState();
                      showModalBottomSheet(
                        isScrollControlled: true,
                        backgroundColor: Colors.white,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(24),
                          ),
                        ),
                        context: context,
                        builder: (context) {
                          return const DiaryPasswordSetting();
                        },
                      );
                    },
                    child: const Text("Impostazione password diario fittizio"),
                  ),
                ],
                const Expanded(child: NoteListWidget()),
              ],
            );
          },
        ),
        floatingActionButton: const NoteActionsWidget(),
      ),
    );
  }
}
