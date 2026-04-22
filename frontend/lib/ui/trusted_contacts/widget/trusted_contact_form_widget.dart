import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_model/trusted_contact_view_model.dart';
import '../../../domain/models/trusted_contact.dart';

/// Gestisce i campi di input per l'inserimento o la modifica di un contatto fidato.
///
/// In quanto Consumer di [TrustedContactViewModel], si aggiorna in base allo
/// stato del ViewModel. Può essere inizializzato con un [initialContact]
/// per operare in modalità modifica.
class TrustedContactFormWidget extends StatefulWidget {
  /// Callback invocata quando il form viene chiuso (annullato o salvato).
  final VoidCallback onDismiss;

  /// Contatto opzionale da modificare. Se null, il form opera in modalità creazione.
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
    // Inizializza i controller con i dati del contatto esistente o vuoti
    _nameController = TextEditingController(
      text: widget.initialContact?.getName(),
    );
    _emailController = TextEditingController(
      text: widget.initialContact?.getEmail(),
    );
    _phoneController = TextEditingController(
      text: widget.initialContact?.getPhone(),
    );
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
    final viewModel = context.watch<TrustedContactViewModel>();
    final isEditing = widget.initialContact != null;

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
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
                  color: Colors.teal.shade400,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  isEditing ? 'Modifica Contatto' : 'Nuovo Contatto Fidato',
                  style: const TextStyle(
                    fontSize: 18,
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
            ElevatedButton(
              onPressed:
                  viewModel.createContact.running ||
                      viewModel.updateContact.running
                  ? null
                  : () {
                      if (_formKey.currentState!.validate()) {
                        final contact = TrustedContact(
                          id: widget.initialContact?.getId() ?? '',
                          name: _nameController.text.trim(),
                          email: _emailController.text.trim(),
                          phoneNumber: _phoneController.text.trim(),
                        );

                        if (isEditing) {
                          viewModel.updateContact.execute(contact);
                        } else {
                          viewModel.createContact.execute(contact);
                        }
                        widget.onDismiss();
                      }
                    },
              child: Text(
                isEditing ? 'Aggiorna contatto' : 'Salva contatto',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
