import 'package:flutter/material.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/chat/widget/chat_screen.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/diary/view_model/diary_viewmodel.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/diary/widget/note_list_widget.dart';
import 'package:provider/provider.dart';

class DiaryScreen extends StatelessWidget {
  const DiaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final viewmodel = DiaryViewmodel();
      },
      child: const DiaryScreenView(),
    );
  }
}

class DiaryScreenView extends StatelessWidget {
  const DiaryScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      /*onForcePressPeak: () {
        ///Richiesta conferma eliminazione nota
      },*/

      //Da vedere come fare per l'accesso
      child: Scaffold(
        onDrawerChanged: (isOpened) {
          if (isOpened) {
            FocusManager.instance.primaryFocus?.unfocus();
          }
        },
        appBar: AppBar(
          title: const _AppBarTitle(),
          actions: [
            ///CreateNewNoteWidget,
            ///
          ],
        ),
      ),
    );
  }
}

class _AppBarTitle extends StatelessWidget {
  const _AppBarTitle();

  @override
  Widget build(BuildContext context) {
    final title = context.select<DiaryViewmodel, String>(
      (vm) => vm.getCurrentNote()?.getTitle() ?? 'Nuova nota',
    );
    return Text(title);
  }
}
