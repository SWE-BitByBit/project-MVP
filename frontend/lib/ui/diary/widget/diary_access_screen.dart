import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/diary/view_model/diary_access_viewmodel.dart';
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
  DiaryAccessView createState() => DiaryAccessView();
}

class DiaryAccessView extends State<DiaryAccess> {
  final _diaryPassword = TextEditingController();

  @override
  void dispose() {
    _diaryPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DiaryAccessViewmodel>();
    return Scaffold(
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
