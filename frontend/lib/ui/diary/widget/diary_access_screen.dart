import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/diary/view_model/diary_access_view_model.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/diary/widget/password_form_widget.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/diary/widget/diary_first_setup_widget.dart'; // Importa il nuovo widget

class DiaryAccessScreenView extends StatelessWidget {
  const DiaryAccessScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DiaryAccessViewModel>(
      builder: (context, vm, child) {
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Text(vm.needsInitialSetup ? 'Configurazione' : 'Accesso al diario'),
            centerTitle: true,
            backgroundColor: Colors.teal.shade200,
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: _buildBody(vm),
            ),
          ),
        );
      },
    );
  }

  // Funzione helper snella per decidere cosa mostrare nel body
  Widget _buildBody(DiaryAccessViewModel vm) {
    // Spinner per check iniziale o operazioni in corso
    if (vm.isCheckingStatus || vm.login.isRunning.value || vm.createInitialPassword.isRunning.value) {
      return const CircularProgressIndicator();
    }

    // Se serve il setup, mostra il nuovo widget dedicato
    if (vm.needsInitialSetup) {
      return const DiaryFirstSetupWidget();
    }

    // Altrimenti, mostra il form di login classico
    return PasswordFormWidget(onDismiss: () {});
  }
}