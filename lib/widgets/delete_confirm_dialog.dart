import 'package:flutter/material.dart';

import '../core/app_theme.dart';

/// Shows an AlertDialog. Returns true only when the user taps Delete.
Future<bool> showDeleteConfirmDialog(
  BuildContext context, {
  required String title,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        icon: const Icon(
          Icons.delete_outline_rounded,
          color: AppColors.expense,
          size: 34,
        ),
        title: const Text('Delete transaction?'),
        content: Text(
          '"$title" will be permanently removed. This action cannot be undone.',
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.expense),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      );
    },
  );
  return result ?? false;
}