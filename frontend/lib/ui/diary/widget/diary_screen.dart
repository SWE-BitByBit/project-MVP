import 'package:flutter/material.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/diary/view_model/diary_viewmodel.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/diary/widget/note_list_widget.dart';

class DiaryScreen extends StatelessWidget {
  const DiaryScreen({super.key, required this.viewmodel});

  final DiaryViewmodel viewmodel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(drawer: const NoteListWidget());
  }
}
