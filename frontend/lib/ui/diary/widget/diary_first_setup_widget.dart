import 'package:flutter/material.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/diary/view_model/diary_access_view_model.dart';
import 'package:provider/provider.dart';

class DiaryFirstSetupWidget extends StatefulWidget {
  const DiaryFirstSetupWidget({super.key});

  @override
  State<DiaryFirstSetupWidget> createState() => _DiaryFirstSetupWidgetState();
}

class _DiaryFirstSetupWidgetState extends State<DiaryFirstSetupWidget> {
  late final TextEditingController _pwdController;
  late final TextEditingController _confirmController;

  @override
  void initState() {
    super.initState();
    _pwdController = TextEditingController();
    _confirmController = TextEditingController();
  }

  @override
  void dispose() {
    _pwdController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Usiamo context.watch perché vogliamo che il widget si ricostruisca
    // se viewModel.passwordError cambia
    final vm = context.watch<DiaryAccessViewModel>();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.shield_outlined, size: 80, color: Colors.teal),
          const SizedBox(height: 24),
          const Text(
            "Benvenuto!",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            "Imposta la tua password per il diario reale. Questa sarà la chiave principale per i tuoi segreti.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 32),

          TextField(
            controller: _pwdController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Crea Password Principale',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.lock_open),
            ),
            onChanged: (val) => vm.validateInput(val),
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _confirmController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Conferma Password',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.lock_outline),
            ),
          ),

          if (vm.passwordError.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                vm.passwordError,
                style: const TextStyle(color: Colors.red, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),

          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                if (_pwdController.text == _confirmController.text) {
                  FocusScope.of(context).unfocus();
                  vm.createInitialPassword.run(_pwdController.text);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Le password non coincidono")),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
              child: const Text(
                'Attiva Diario',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}