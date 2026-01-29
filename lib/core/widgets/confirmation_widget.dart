import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ConfirmationDialog {
  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Yes',
    String cancelText = 'No',
    Color? confirmColor,
    Color? cancelColor,
    IconData? icon, // icon ignored in Cupertino (by design)
  }) async {
    final result = await showCupertinoDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return CupertinoAlertDialog(
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          content: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(message, style: const TextStyle(fontSize: 14)),
          ),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(
                cancelText,
                style: TextStyle(
                  color: cancelColor ?? CupertinoColors.systemGrey,
                ),
              ),
            ),
            CupertinoDialogAction(
              isDestructiveAction:
                  (confirmColor == null || confirmColor == Colors.red),
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(
                confirmText,
                style: TextStyle(
                  color:
                      confirmColor != null
                          ? Color(confirmColor.value)
                          : CupertinoColors.systemRed,
                ),
              ),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }
}
