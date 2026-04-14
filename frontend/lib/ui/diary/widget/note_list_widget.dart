import 'package:flutter/material.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/diary/view_model/diary_viewmodel.dart';
import 'package:provider/provider.dart';

class NoteListWidget extends StatelessWidget {
  const NoteListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    //return ChangeNotifierProvider()
    return Scaffold(
      /*body: ListenableBuilder(
        listenable: viewmodel,
        builder: (context, _) {
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: viewmodel.getSavedNotes().length,
            itemBuilder: (context, index) {
              final note = viewmodel.getSavedNotes()[index];
              return Card(
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => NotePage))
                  },
                )
              );
            },
          );
        },
      ),*/
    );
  }
}
