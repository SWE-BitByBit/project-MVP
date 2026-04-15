import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Importa il pacchetto per le variabili d'ambiente
import 'ui/home/widget/home_screen.dart';
import 'data/services/auth_service.dart';
import 'data/repositories/auth_repository.dart';

/// Punto di ingresso principale dell'applicazione.
///
/// Inizializza le configurazioni di sistema e carica le variabili d'ambiente
/// prima di avviare l'interfaccia utente tramite [runApp].
Future<void> main() async {
  // Assicura che i servizi dei widget di Flutter siano inizializzati.
  // È obbligatorio chiamarlo se si eseguono operazioni asincrone nel main.
  WidgetsFlutterBinding.ensureInitialized();

  // Carica il file delle configurazioni segrete (.env).
  // In caso di errore (file mancante), l'app stamperà l'errore in console.
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Attenzione: Impossibile caricare il file .env: $e");
  }

  final authService = AuthService();
  final authRepository = AuthRepository(authService);

  runApp(MainApp(authRepository: authRepository));
}

/// Classe principale che configura il tema e la navigazione dell'applicazione.
class MainApp extends StatelessWidget {
  /// Repository per la gestione dell'autenticazione.
  final AuthRepository authRepository;

  /// Inizializza l'applicazione con il [authRepository] fornito.
  const MainApp({super.key, required this.authRepository});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'L\'App che Protegge e Trasforma',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: HomeScreen(authRepository: authRepository),
    );
  }
}
