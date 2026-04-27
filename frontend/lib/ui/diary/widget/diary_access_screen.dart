import 'package:flutter/material.dart';
import 'package:mvp_app_protegge_e_trasforma/data/repositories/diary_account_repository.dart';
import 'package:mvp_app_protegge_e_trasforma/data/services/diary_account_service.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/diary/view_model/diary_access_viewmodel.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/diary/widget/password_form_widget.dart';
import 'package:provider/provider.dart';

/// Pagina per l'accesso al diario.
///
/// Istanzia le dipendenze e poi fa dependency injection tramite [ChangeNotifierProvider]
/// Logica di stato e l'effettiva costruzione della UI sono delegate ai widget
class DiaryAccessScreen extends StatelessWidget {
  const DiaryAccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        final service = DiaryAccountService();
        final repo = DiaryAccountRepository(service);
        final viewmodel = DiaryAccessViewmodel(repo);
        return viewmodel;
      },
      child: const DiaryAccessScreenView(),
    );
  }
}

/// Vista pura
///
/// Si occupa della creazione dell'interfaccia di accesso, e ,in quanto Consumer di [DiaryAccessViewmodel]
/// si aggiorna in seguito a cambiamenti di stato del ViewModel
class DiaryAccessScreenView extends StatelessWidget {
  const DiaryAccessScreenView({super.key});

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
              if (vm.error != null)
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
                          vm.error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(child: PasswordFormWidget(onDismiss: () {})),
            ],
          ),
        ),
      ),
    );
  }
}
