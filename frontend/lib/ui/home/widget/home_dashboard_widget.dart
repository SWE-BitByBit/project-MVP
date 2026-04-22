import 'package:flutter/material.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/diary/widget/diary_access_screen.dart';
import 'package:provider/provider.dart';
import '../view_model/home_view_model.dart';
import '../../core/widgets/dashboard_button_widget.dart';
import '../../chat/widget/chat_screen.dart';
import '../../trusted_contacts/widget/trusted_contacts_screen.dart';
import '../../material/widget/material_screen.dart';

/// Visualizza la griglia dei pulsanti principali della dashboard.
///
/// Implementa il pattern Consumer tramite [context.watch] per osservare
/// il [HomeViewModel] e reagire dinamicamente ai cambiamenti di stato,
/// aggiornando l'interfaccia grafica ad ogni notifica.
class HomeDashboardWidget extends StatelessWidget {
  const HomeDashboardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HomeViewModel>();

    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: 4,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        if (index == 0) {
          return DashboardButtonWidget(
            title: 'Supporto Chat',
            description:
                'Parla con un assistente virtuale in modo sicuro, anonimo e immediato.',
            icon: Icons.chat_bubble_outline,
            backgroundColor: Colors.blue.shade50,
            iconColor: Colors.blue.shade800,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChatScreen()),
              );
            },
          );
        } else if (index == 1) {
          return DashboardButtonWidget(
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
                  builder: (context) => const TrustedContactScreen(),
                ),
              );
            },
          );
        } else if (index == 2) {
          return DashboardButtonWidget(
            title: 'Il mio Diario',
            description:
                'Il tuo spazio personale e protetto per scrivere e tenere traccia di ogni cosa.',
            icon: Icons.edit_note,
            backgroundColor: Colors.purple.shade50,
            iconColor: Colors.purple.shade800,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DiaryAccessScreen(),
                ),
              );
            },
          );
        } else {
          return DashboardButtonWidget(
            title: 'Informazioni',
            description:
                'Risorse utili, guide e contatti nazionali per la tua sicurezza e i tuoi diritti.',
            icon: Icons.menu_book,
            backgroundColor: Colors.orange.shade50,
            iconColor: Colors.orange.shade800,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MaterialScreen()),
              );
            },
          );
        }
      },
    );
  }
}
