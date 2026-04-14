import 'package:flutter/material.dart';
import '../../../../data/services/auth_service.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../view_model/auth_view_model.dart';
import 'header_widget.dart';
import 'google_login_button_widget.dart';
import 'logged_in_banner_widget.dart';

/// Rappresenta la schermata principale per l'autenticazione dell'utente.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Inizializziamo la nostra catena di architettura
  late final AuthService _authService;
  late final AuthRepository _authRepository;
  late final AuthViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _authService = AuthService();
    _authRepository = AuthRepository(_authService);
    _viewModel = AuthViewModel(_authRepository);
  }

  @override
  void dispose() {
    _viewModel.dispose(); // Pulizia della memoria quando si chiude la schermata
    super.dispose();
  }

  /// Costruisce l'interfaccia utente combinando i vari widget.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: Colors.teal.shade200,
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: ListenableBuilder(
              // ListenableBuilder "ascolta" il ViewModel.
              // Quando il ViewModel chiama notifyListeners(), questa parte si ridisegna!
              listenable: _viewModel,
              builder: (context, child) {
                final isUserLoggedIn = _viewModel.currentUser != null;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. HEADER (Sempre visibile)
                    const HeaderWidget(),
                    const SizedBox(height: 48),

                    // Mostra un messaggio di errore se il ViewModel ne ha uno
                    if (_viewModel.errorMessage != null) ...[
                      Text(
                        _viewModel.errorMessage!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                    ],

                    // 2. LOGICA CONDIZIONALE: Bottone o Banner?
                    if (isUserLoggedIn) ...[
                      // Se è loggato, mostra il banner passandogli l'email
                      LoggedInBannerWidget(
                        email: _viewModel.currentUser!.email,
                      ),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () => _viewModel.logout(),
                        child: const Text(
                          'Disconnetti',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ] else ...[
                      // Se NON è loggato, mostra il bottone Google
                      GoogleLoginButtonWidget(
                        isLoading: _viewModel.isLoading,
                        onPressedCallback: () async {
                          await _viewModel.login();
                          // In futuro qui metteremo il codice per navigare alla HomePage!
                        },
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'L\'accesso è consentito solo tramite account Google ufficiale.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
