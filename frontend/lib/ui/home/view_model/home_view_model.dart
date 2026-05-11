import 'package:flutter/material.dart';
import 'package:command_it/command_it.dart';

import '../../../data/repositories/dead_man_repository.dart';
import '../../../domain/models/core/dashboard_item.dart';

class HomeViewModel extends ChangeNotifier {
  final DeadManRepository _deadManRepository;

  late final Command<void, List<DashboardItem>> loadDashboard;

  HomeViewModel(this._deadManRepository) {
    loadDashboard = Command.createSyncNoParam<List<DashboardItem>>(
      _loadDashboardItems,
      initialValue: [],
    );
    loadDashboard.run();
  }

  bool get isDeadManActive =>
      _deadManRepository.currentSettings?.isActive ?? false;

  List<DashboardItem> _loadDashboardItems() {
    return [
      DashboardItem(
        title: 'Contatti Fidati',
        description: 'La tua rete di emergenza pronta ad aiutarti.',
        icon: Icons.group,
        backgroundColor: Colors.teal.shade50,
        iconColor: Colors.teal.shade800,
        routeName: '/contacts',
      ),
      DashboardItem(
        title: 'Informazioni',
        description:
            'Risorse, guide e contatti nazionali per la tua sicurezza.',
        icon: Icons.menu_book,
        backgroundColor: Colors.orange.shade50,
        iconColor: Colors.orange.shade800,
        routeName: '/materials',
      ),
      DashboardItem(
        title: 'Luoghi Sicuri',
        description:
            'Trova i centri di supporto e i luoghi sicuri più vicini a te.',
        icon: Icons.map_outlined,
        backgroundColor: Colors.green.shade50,
        iconColor: Colors.green.shade800,
        routeName: '/safeplace',
      ),
    ];
  }

  @override
  void dispose() {
    loadDashboard.dispose();
    super.dispose();
  }
}
