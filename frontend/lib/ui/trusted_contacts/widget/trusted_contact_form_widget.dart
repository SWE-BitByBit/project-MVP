import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_model/trusted_contact_view_model.dart';
import '../../../domain/models/trusted_contact/trusted_contact.dart';

/// Gestisce i campi di input per l'inserimento o la modifica di un contatto fidato.
class TrustedContactFormWidget extends StatefulWidget {
  /// Callback invocata quando il form viene salvato con successo o annullato.
  final VoidCallback onDismiss;

  final TrustedContact? initialContact;

  const TrustedContactFormWidget({
    super.key,
    required this.onDismiss,
    this.initialContact,
  });

  @override
  State<TrustedContactFormWidget> createState() =>
      _TrustedContactFormWidgetState();
}

class _TrustedContactFormWidgetState extends State<TrustedContactFormWidget> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    // Inizializza i controller con i dati pubblici del contatto esistente
    _nameController = TextEditingController(text: widget.initialContact?.name);
    _emailController = TextEditingController(text: widget.initialContact?.email);
    _phoneController = TextEditingController(text: widget.initialContact?.phoneNumber);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<TrustedContactViewModel>();
    final isEditing = widget.initialContact != null;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SafeArea(
        child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  isEditing ? Icons.edit_note : Icons.person_add_alt_1,
                  color: theme.colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  isEditing ? 'Modifica Contatto' : 'Nuovo Contatto Fidato',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nome e Cognome',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'Inserisci il nome'
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Numero di Cellulare',
                prefixIcon: const Icon(Icons.phone),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'Inserisci il numero di telefono'
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Indirizzo Email',
                prefixIcon: const Icon(Icons.email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'Inserisci l\'email'
                  : null,
            ),
            const SizedBox(height: 24),

            ValueListenableBuilder<bool>(
              valueListenable: isEditing
                  ? viewModel.updateContact.isRunning
                  : viewModel.createContact.isRunning,
              builder: (context, isRunning, child) {

                return ElevatedButton(
                  // Se sta caricando, disabuilita il bottone
                  onPressed: isRunning ? null : () async {
                    if (_formKey.currentState!.validate()) {
                      FocusScope.of(context).unfocus();

                      final contact = TrustedContact(
                        id: widget.initialContact?.id ?? '',
                        name: _nameController.text.trim(),
                        email: _emailController.text.trim(),
                        phoneNumber: _phoneController.text.trim(),
                      );

                      if (isEditing) {
                        await viewModel.updateContact.runAsync(contact);

                        if (viewModel.updateContact.errors.value == null && context.mounted) {
                          widget.onDismiss();
                        }
                      } else {
                        await viewModel.createContact.runAsync(contact);

                        if (viewModel.createContact.errors.value == null && context.mounted) {
                          widget.onDismiss();
                        }
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isRunning
                      ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: theme.colorScheme.onPrimary),
                  )
                      : Text(
                    isEditing ? 'Aggiorna contatto' : 'Salva contatto',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    ),
    );
  }
}