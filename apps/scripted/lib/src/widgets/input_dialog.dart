import 'package:flutter/material.dart';

Future<double?> showInputDialog(BuildContext context) {
  final TextEditingController controller = TextEditingController();

  return showDialog<double>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Enter a threshold for this stream'),
      content: TextField(
        controller: controller,
        keyboardType:
            const TextInputType.numberWithOptions(decimal: true, signed: false),
        decoration: const InputDecoration(
          hintText: 'Enter a number',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null), // Cancel
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final text = controller.text;
            final value = double.tryParse(text);
            if (value != null) {
              Navigator.of(context).pop(value);
            } else {
              // Optionally show an error or shake the dialog
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please enter a valid number')),
              );
            }
          },
          child: const Text('Confirm'),
        ),
      ],
    ),
  );
}
