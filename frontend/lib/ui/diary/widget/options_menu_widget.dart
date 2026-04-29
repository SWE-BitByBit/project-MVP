import 'package:flutter/material.dart';

class OptionsMenu<T> extends StatelessWidget {
  final List<PopupMenuEntry<T>> items;
  final ValueChanged<T>? onSelected;
  final Icon icon;

  const OptionsMenu({
    super.key,
    required this.items,
    this.onSelected,
    this.icon = const Icon(Icons.more_vert),
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<T>(
      offset: const Offset(0, 40),
      icon: icon,
      itemBuilder: (context) => items,
      onSelected: onSelected,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
