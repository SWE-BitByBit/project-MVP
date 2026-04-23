import 'package:flutter/material.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/diary_session.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/diary/view_model/diary_access_viewmodel.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/diary/widget/diary_screen.dart';
import 'package:provider/provider.dart';

/// Widget che gestisce l'accesso ai diari
///
/// Essendo consumer di [DiaryAccessViewmodel] si aggiorna in seguito a cambiamenti di stato del ViewModel
class PasswordFormWidget extends StatefulWidget {
  final VoidCallback onDismiss;
  const PasswordFormWidget({super.key, required this.onDismiss});

  @override
  State<PasswordFormWidget> createState() => _PasswordFormWidget();
}

class _PasswordFormWidget extends State<PasswordFormWidget> {
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  /// Redirect al diario se l'utente ha effettuato l'accesso
  void _redirect() {
    final diarySession = DiarySession.session;
    final vm = context.read<DiaryAccessViewmodel>();
    if (vm.accessStatus && diarySession.isDiaryAuth == true) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DiaryScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.read<DiaryAccessViewmodel>();
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text('Accedi al diario'),
              const SizedBox(height: 26),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password diario',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 26),
              SizedBox(
                width: double.infinity,
                height: 49,

                child: ElevatedButton(
                  onPressed: () {
                    vm.login(_passwordController.text);
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _redirect();
                    });
                  },
                  child: const Text('Accedi'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
