import 'package:flutter/material.dart';

class TagChip extends StatelessWidget {
  final String label;
  final String? value;
  final bool editable;
  final bool deletable;
  final VoidCallback? onDelete;
  final ValueChanged<String>? onChanged;

  const TagChip({
    super.key,
    required this.label,
    this.value,
    this.editable = false,
    this.deletable = false,
    this.onDelete,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final displayText = value != null && value!.isNotEmpty
        ? '$label: $value'
        : label;

    if (editable && onChanged != null) {
      return RawChip(
        label: Text(displayText),
        onPressed: () => _showEditDialog(context),
        deleteIcon: deletable ? const Icon(Icons.close, size: 16) : null,
        onDeleted: deletable ? onDelete : null,
      );
    }

    return Chip(
      label: Text(displayText),
      deleteIcon: deletable ? const Icon(Icons.close, size: 16) : null,
      onDeleted: deletable ? onDelete : null,
    );
  }

  void _showEditDialog(BuildContext context) {
    final controller = TextEditingController(text: value ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edit $label'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(hintText: label),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              onChanged?.call(controller.text.trim());
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
