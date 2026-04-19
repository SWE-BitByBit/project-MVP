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
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      selectedColor: Colors.teal.shade100,
      checkmarkColor: Colors.teal.shade900,
    );
  }
}
