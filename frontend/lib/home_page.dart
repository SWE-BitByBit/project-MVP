import 'package:flutter/material.dart';
import 'dashboard_button.dart';
import 'trusted_contacts_page.dart';

/// Rappresenta la schermata principale dell'applicazione.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  /// Apre un pannello modale a scorrimento dal basso che espone il pulsante SOS di emergenza.
  ///
  /// Il pannello viene presentato tramite [showModalBottomSheet] e contiene un'intestazione
  /// "Azioni Rapide" e un pulsante rosso che, una volta premuto, registra la pressione
  /// e chiude il modale tramite [Navigator.pop].
  /// Richiede il [context] corrente per ancorare il modale all'albero dei widget.
  void _showEmergencyMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 5,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const Text(
                'Azioni Rapide',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    print("SOS PREMUTO DAL MENU NASCOSTO!");
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.warning,
                    color: Colors.white,
                    size: 28,
                  ),
                  label: const Text(
                    'SOS',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  /// Costruisce la schermata principale dell'applicazione.
  ///
  /// Restituisce uno [Scaffold] composto da:
  /// - una [AppBar] con titolo centrato, un'icona profilo a sinistra e un'icona impostazioni a destra;
  /// - un corpo con una [ListView.separated] da quattro voci, ognuna rappresentata da un [DashboardButton];
  /// - un [FloatingActionButton] centrato in basso che, al tocco, invoca [_showEmergencyMenu].
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
            print("Vai al Profilo Utente!");
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, size: 28, color: Colors.teal.shade900),
            onPressed: () {
              print("Vai alle Impostazioni!");
            },
          ),
          const SizedBox(width: 10),
        ],
      ),

      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: 4,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            if (index == 0) {
              return DashboardButton(
                title: 'Supporto Chat',
                description:
                    'Parla con un assistente virtuale in modo sicuro, anonimo e immediato.',
                icon: Icons.chat_bubble_outline,
                backgroundColor: Colors.blue.shade50,
                iconColor: Colors.blue.shade800,
                onTap: () {
                  print("Hai cliccato Supporto Chat!");
                },
              );
            } else if (index == 1) {
              return DashboardButton(
                title: 'Contatti Fidati',
                description:
                    'Gestisci la tua rete di emergenza pronta ad aiutarti con un solo tocco.',
                icon: Icons.group,
                backgroundColor: Colors.teal.shade50,
                iconColor: Colors.teal.shade800,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TrustedContactsPage(),
                    ),
                  );
                },
              );
            } else if (index == 2) {
              return DashboardButton(
                title: 'Il mio Diario',
                description:
                    'Il tuo spazio personale e protetto per scrivere e tenere traccia di ogni cosa.',
                icon: Icons.edit_note,
                backgroundColor: Colors.purple.shade50,
                iconColor: Colors.purple.shade800,
                onTap: () {
                  print("Hai cliccato Diario!");
                },
              );
            } else {
              return DashboardButton(
                title: 'Informazioni',
                description:
                    'Risorse utili, guide e contatti nazionali per la tua sicurezza e i tuoi diritti.',
                icon: Icons.menu_book,
                backgroundColor: Colors.orange.shade50,
                iconColor: Colors.orange.shade800,
                onTap: () {
                  print("Hai cliccato Informazioni!");
                },
              );
            }
          },
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FloatingActionButton(
          onPressed: () => _showEmergencyMenu(context),
          backgroundColor: Colors.teal.shade50,
          elevation: 0,
          child: Icon(
            Icons.keyboard_arrow_up,
            color: Colors.teal.shade800,
            size: 30,
          ),
        ),
      ),
    );
  }
}
