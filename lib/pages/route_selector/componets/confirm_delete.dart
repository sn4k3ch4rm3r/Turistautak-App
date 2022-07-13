import 'package:flutter/material.dart';

class ConfirmDeleteDialog extends StatelessWidget {
  final String routeName;
  const ConfirmDeleteDialog({Key? key, required this.routeName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Törlés megerősítése',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface
        ),
      ),
      content: Text(
        'Biztosan törölni akarod a "$routeName" nevű útvonalat?',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('Mégse'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text('Igen'),
        ),
      ],
    );
  }
}