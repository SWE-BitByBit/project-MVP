import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/diary_session.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/diary/view_model/diary_viewmodel.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/diary/widget/diary_access_screen.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/diary/widget/note_action_new_widget.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/diary/widget/note_list_widget.dart';
import 'package:provider/provider.dart';

class DiaryScreen extends StatelessWidget {
  const DiaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = DiarySession.session;
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
        final viewmodel = DiaryViewmodel();
        final diarySession = DiarySession.session;

        if (diarySession.isDiaryAuth != null) {
          viewmodel.loadPreviews(diarySession.loggedDiary!);
        }
        return viewmodel;
      },
      child: const DiaryScreenView(),
    );
  }
}

class DiaryScreenView extends StatelessWidget {
  const DiaryScreenView({super.key});
  @override
  Widget build(BuildContext context) {
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
            return Column(children: [const Expanded(child: NoteListWidget())]);
          },
        ),
        floatingActionButton: const NoteActionNewWidget(),
      ),
    );
  }
}
