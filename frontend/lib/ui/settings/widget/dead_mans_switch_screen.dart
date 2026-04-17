import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_model/dead_mans_switch_view_model.dart';

class DeadMansSwitchScreen extends StatelessWidget {
  const DeadMansSwitchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DeadMansSwitchViewModel(),
      child: const DeadMansSwitchScreenView(),
    );
  }
}

class DeadMansSwitchScreenView extends StatelessWidget {
  const DeadMansSwitchScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dead Man\'s Switch'),
        centerTitle: true,
        backgroundColor: Colors.teal.shade200,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.teal.shade900),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Consumer<DeadMansSwitchViewModel>(
        builder: (context, viewModel, child) {
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              if (viewModel.error != null)
                Container(
                  color: Colors.red.shade50,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          viewModel.error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red, size: 18),
                        onPressed: viewModel.clearError,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
              SwitchListTile(
                title: const Text('Attiva Dead Man\'s Switch'),
                subtitle: const Text('Verifica inattività e invia allarme'),
                value: viewModel.isActive,
                onChanged: viewModel.toggleActive,
                activeColor: Colors.teal,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 24),
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: 'Primo timer',
                  border: OutlineInputBorder(),
                ),
                value: viewModel.firstTimerMinutes,
                items: [5, 10, 15, 30, 60].map((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text('$value minuti'),
                  );
                }).toList(),
                onChanged: viewModel.isActive
                    ? (value) {
                        if (value != null) viewModel.setFirstTimer(value);
                      }
                    : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: 'Secondo timer',
                  border: OutlineInputBorder(),
                ),
                value: viewModel.secondTimerMinutes,
                items: [1, 2, 5, 10, 15].map((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text('$value minuti'),
                  );
                }).toList(),
                onChanged: viewModel.isActive
                    ? (value) {
                        if (value != null) viewModel.setSecondTimer(value);
                      }
                    : null,
              ),
            ],
          );
        },
      ),
    );
  }
}