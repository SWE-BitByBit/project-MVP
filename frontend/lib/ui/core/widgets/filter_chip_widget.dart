import 'package:flutter/material.dart';

/// Widget di supporto per disegnare un singolo chip di filtro.
class FilterChipWidget extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  const FilterChipWidget({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  /// Costruisce visivamente il singolo elemento chip configurandolo con i colori di tema e associando il comando [onSelected].
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      // Sfondo quando selezionato
      selectedColor: colorScheme.primaryContainer,
      // Colore della spunta
      checkmarkColor: colorScheme.onPrimaryContainer,
    );
  }
}