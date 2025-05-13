import 'package:flutter/material.dart';

class FieldLabel extends StatelessWidget {
  final String label;
  final String tooltip;

  const FieldLabel({super.key, required this.label, required this.tooltip});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 4),
        Tooltip(
          message: tooltip,
          child: InkWell(
            child: const Icon(Icons.info_outline, size: 18, color: Colors.grey),
            onTap: () {
              // Optional: You can show a dialog or snackbar here instead
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(tooltip)),
              );
            },
          ),
        ),
      ],
    );
  }
}
