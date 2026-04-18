import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../view_model/dead_mans_switch_view_model.dart';
import '../../core/widgets/error_banner_widget.dart';

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
                ErrorBannerWidget(
                  error: viewModel.error!,
                  onClose: viewModel.clearError,
                ),
              SwitchListTile(
                title: const Text('Attiva Dead Man\'s Switch'),
                subtitle: const Text('Verifica inattività e invia allarme'),
                value: viewModel.isActive,
                onChanged: viewModel.toggleActive,
                activeThumbColor: Colors.teal,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 24),
              _TimerRow(
                label: 'Primo timer',
                value: viewModel.firstTimerValue,
                unit: viewModel.firstTimerUnit,
                isActive: viewModel.isActive,
                onValueChanged: viewModel.setFirstTimerValue,
                onUnitChanged: viewModel.setFirstTimerUnit,
              ),
              const SizedBox(height: 16),
              _TimerRow(
                label: 'Secondo timer',
                value: viewModel.secondTimerValue,
                unit: viewModel.secondTimerUnit,
                isActive: viewModel.isActive,
                onValueChanged: viewModel.setSecondTimerValue,
                onUnitChanged: viewModel.setSecondTimerUnit,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TimerRow extends StatelessWidget {
  final String label;
  final int value;
  final String unit;
  final bool isActive;
  final Function(int) onValueChanged;
  final Function(String) onUnitChanged;

  const _TimerRow({
    required this.label,
    required this.value,
    required this.unit,
    required this.isActive,
    required this.onValueChanged,
    required this.onUnitChanged,
  });

  @override
  Widget build(BuildContext context) {
    final unitaMisura = ['Ore', 'Giorni', 'Settimane'];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: TextFormField(
            initialValue: value.toString(),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: label,
              border: const OutlineInputBorder(),
            ),
            enabled: isActive,
            onChanged: (val) {
              final parsed = int.tryParse(val);
              if (parsed != null) onValueChanged(parsed);
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 1,
          child: DropdownButtonFormField<String>(
            decoration: const InputDecoration(border: OutlineInputBorder()),
            value: unit,
            items: unitaMisura.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
            onChanged: isActive ? (val) { if (val != null) onUnitChanged(val); } : null,
          ),
        ),
      ],
    );
  }
}