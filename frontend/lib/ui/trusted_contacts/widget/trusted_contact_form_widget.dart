import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_model/trusted_contact_view_model.dart';

/// Gestisce i campi di input per l'inserimento di un nuovo contatto fidato.
///
/// In quanto Consumer di [TrustedContactViewModel], si aggiorna in base allo
/// stato del ViewModel, ad esempio per ripristinare il form dopo la creazione
/// o per visualizzare un errore di validazione.
class TrustedContactFormWidget extends StatefulWidget {
  /// Callback invocata quando il form viene chiuso (annullato o salvato).
  final VoidCallback onDismiss;

  const TrustedContactFormWidget({super.key, required this.onDismiss});

  @override
  State<TrustedContactFormWidget> createState() =>
      _TrustedContactFormWidgetState();
}

class _TrustedContactFormWidgetState extends State<TrustedContactFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  /// Valida i campi e, in caso di successo, invoca [TrustedContactViewModel.createContact].
  ///
  /// Al termine dell'operazione chiude il form tramite [widget.onDismiss].
  Future<void> _submitForm(TrustedContactViewModel viewModel) async {
    if (_formKey.currentState!.validate()) {
      await viewModel.createContact(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
      );
      widget.onDismiss();
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<TrustedContactViewModel>();

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
                Icon(Icons.person_add_alt_1,
                    color: Colors.teal.shade400, size: 28),
                const SizedBox(width: 12),
                const Text(
                  'Nuovo Contatto Fidato',
                  style: TextStyle(
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
                    borderRadius: BorderRadius.circular(12)),
              ),
              validator: (value) =>
                  (value == null || value.trim().isEmpty) ? 'Inserisci il nome' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Numero di Cellulare',
                prefixIcon: const Icon(Icons.phone),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              validator: (value) =>
                  (value == null || value.trim().isEmpty) ? 'Inserisci il numero' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Indirizzo Email',
                prefixIcon: const Icon(Icons.email),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              validator: (value) =>
                  (value == null || value.trim().isEmpty) ? 'Inserisci l\'email' : null,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: viewModel.isLoading ? null : () => _submitForm(viewModel),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: viewModel.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : const Text(
                      'Salva contatto',
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
