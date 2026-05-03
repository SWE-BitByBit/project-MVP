import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/widgets/error_indicator.dart';
import '../view_model/dead_man_view_model.dart';

/// Widget principale per la schermata di configurazione del Dead Man's Switch.
class DeadManFormWidget extends StatefulWidget {
  const DeadManFormWidget({super.key});

  @override
  State<DeadManFormWidget> createState() => _DeadManFormWidgetState();
}

class _DeadManFormWidgetState extends State<DeadManFormWidget> {
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<DeadManViewModel>();
      vm.saveSettings.errors.addListener(() {
        if (vm.saveSettings.errors.value != null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Errore durante il salvataggio. Riprova.'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      });
    });
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _syncTextControllers(DeadManViewModel vm) {
    final draft = vm.draftSettings;
    if (draft == null) return;

    if (_subjectController.text != draft.messageSubject) {
      _subjectController.text = draft.messageSubject;
    }
    if (_bodyController.text != draft.messageBody) {
      _bodyController.text = draft.messageBody;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<DeadManViewModel>(
      builder: (context, vm, child) {
        // STATO DI CARICAMENTO INIZIALE
        if (vm.loadSettings.isRunning.value && vm.draftSettings == null) {
          return const Padding(
            padding: EdgeInsets.all(32.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        // STATO DI ERRORE
        if (vm.loadSettings.errors.value != null && vm.draftSettings == null) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ErrorIndicator(
              title: "Impossibile caricare",
              label: "Riprova",
              onPressed: () => vm.loadSettings.run(),
            ),
          );
        }

        final draft = vm.draftSettings;
        if (draft == null) return const SizedBox.shrink();

        _syncTextControllers(vm);

        // IL FORM INTERATTIVO
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- INTERRUTTORE GLOBALE ---
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'Stato Allarme',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  draft.isActive ? 'Attivo e in monitoraggio' : 'Disattivato',
                  style: TextStyle(
                    color: draft.isActive ? theme.colorScheme.primary : theme.colorScheme.outline,
                  ),
                ),
                value: draft.isActive,
                onChanged: (val) => vm.toggleActiveStatus(val),
              ),

              const Divider(),
              const SizedBox(height: 16),

              // --- SLIDER 1 ---
              Text(
                'Invia avviso di check-in dopo:',
                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              Row(
                children: [
                  Expanded(
                    child: Slider(
                      value: draft.firstInactivityTimer.toDouble(),
                      min: 1,
                      max: 10,
                      divisions: 9,
                      label: '${draft.firstInactivityTimer} giorni',
                      onChanged: (val) => vm.updateTimers(firstTimer: val.toInt()),
                    ),
                  ),
                  Text('${draft.firstInactivityTimer} gg', style: theme.textTheme.titleMedium),
                ],
              ),
              const SizedBox(height: 8),

              // --- SLIDER 2 ---
              Text(
                'Se non rispondo, lancia l\'allarme dopo:',
                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              Row(
                children: [
                  Expanded(
                    child: Slider(
                      value: draft.secondInactivityTimer.toDouble(),
                      min: 1,
                      max: 5,
                      divisions: 4,
                      label: '${draft.secondInactivityTimer} giorni',
                      onChanged: (val) => vm.updateTimers(secondTimer: val.toInt()),
                    ),
                  ),
                  Text('${draft.secondInactivityTimer} gg', style: theme.textTheme.titleMedium),
                ],
              ),
              const SizedBox(height: 16),

              // --- CAMPI DI TESTO ---
              TextFormField(
                controller: _subjectController,
                decoration: const InputDecoration(labelText: 'Oggetto Messaggio'),
                onChanged: (text) => vm.updateMessage(text, draft.messageBody),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bodyController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Corpo del Messaggio'),
                onChanged: (text) => vm.updateMessage(draft.messageSubject, text),
              ),

              const SizedBox(height: 24),

              // --- BOTTONE SALVA SINGOLO ---
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ValueListenableBuilder<bool>(
                    valueListenable: vm.saveSettings.isRunning,
                    builder: (context, isSaving, _) {
                      return FilledButton.icon(
                        onPressed: (isSaving || !vm.hasUnsavedChanges)
                            ? null
                            : () async {
                          FocusScope.of(context).unfocus();
                          await vm.saveSettings.runAsync();
                          if (vm.saveSettings.errors.value == null && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Impostazioni salvate!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        },
                        icon: isSaving
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.save),
                        label: const Text('Salva'),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}