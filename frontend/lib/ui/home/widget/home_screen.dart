import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_model/home_view_model.dart';
import 'home_dashboard_widget.dart';
import 'home_actions_widget.dart';
import '../../settings/widget/settings_screen.dart';
import '../../auth/widget/login_screen.dart';
import '../../../data/repositories/auth_repository.dart';

/// Schermata principale dell'applicazione.
///
/// Funge da compositore: istanzia le dipendenze necessarie, le inietta tramite
/// [ChangeNotifierProvider] e delega la logica di stato e la costruzione
/// dell'interfaccia grafica ai widget sottostanti.
class HomeScreen extends StatelessWidget {
  /// Repository per la gestione dell'autenticazione.
  final AuthRepository authRepository;

  /// Inizializza la schermata con il [authRepository] fornito.
  const HomeScreen({super.key, required this.authRepository});

  /// Costruisce l'interfaccia della schermata iniettando il [HomeViewModel].
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeViewModel(),
      child: HomeScreenView(authRepository: authRepository),
    );
  }
}

/// Vista pura della schermata principale.
///
/// Riceve il [HomeViewModel] dal provider e compone il layout unendo
/// [HomeDashboardWidget] per il corpo e [HomeActionsWidget] per il FAB.
class HomeScreenView extends StatelessWidget {
  /// Repository per la gestione dell'autenticazione.
  final AuthRepository authRepository;

  /// Inizializza la vista della home con il [authRepository] fornito.
  const HomeScreenView({super.key, required this.authRepository});

  /// Costruisce il layout della home con [AppBar], dashboard e pulsanti di azione.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        centerTitle: true,
        backgroundColor: Colors.teal.shade200,
        leading: IconButton(
          icon: Icon(
            Icons.account_circle,
            size: 30,
            color: Colors.teal.shade900,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    LoginScreen(authRepository: authRepository),
              ),
            );
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, size: 28, color: Colors.teal.shade900),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Consumer<HomeViewModel>(
        builder: (context, viewModel, child) {
          return Column(
            children: [
              if (viewModel.error != null)
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
                          viewModel.error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Colors.red,
                          size: 18,
                        ),
                        onPressed: viewModel.clearError,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
              const Expanded(child: HomeDashboardWidget()),
            ],
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: const HomeActionsWidget(),
    );
  }
}
