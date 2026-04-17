import 'package:flutter/material.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/diary_session.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/diary/view_model/diary_access_viewmodel.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/diary/widget/diary_screen.dart';
import 'package:provider/provider.dart';

class DiaryAccessScreen extends StatelessWidget {
  const DiaryAccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        final viewmodel = DiaryAccessViewmodel();
        return viewmodel;
      },
      child: DiaryAccess(),
    );
  }
}

class DiaryAccess extends StatefulWidget {
  const DiaryAccess({super.key});
  @override
  DiaryAccessScreenView createState() => DiaryAccessScreenView();
}

class DiaryAccessScreenView extends State<DiaryAccess> {
  final _diaryPassword = TextEditingController();

  @override
  void dispose() {
    _diaryPassword.dispose();
    super.dispose();
  }

  final diarySession = DiarySession.session;
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DiaryAccessViewmodel>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accesso al diario'),
        centerTitle: true,
        backgroundColor: Colors.teal.shade200,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Accedi al diario'),
              SizedBox(height: 26),
              TextField(
                controller: _diaryPassword,
                decoration: InputDecoration(
                  labelText: 'Password diario',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              SizedBox(height: 26),
              SizedBox(
                width: double.infinity,
                height: 49,
                child: ElevatedButton(
                  onPressed: () {
                    vm.login(_diaryPassword.text);
                    //Redirect se l'utente ha effettuato il login con successo
                    if (diarySession.isDiaryAuth != null &&
                        diarySession.isDiaryAuth == true) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DiaryScreen(),
                        ),
                      );
                    }
                  },
                  child: Text('Accedi'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
