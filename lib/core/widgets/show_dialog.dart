import 'package:flutter/cupertino.dart';

/// Global Cupertino dialog utility
class CupertinoDialogUtils {
  /// Shows a Cupertino-style dialog
  static void showCupertinoDialogBox({
    required BuildContext context,
    required String title,
    required String content,
    required List<CupertinoDialogActionModel> actions,
  }) {
    showCupertinoDialog(
      context: context,
      builder:
          (ctx) => CupertinoAlertDialog(
            title: Text(title),
            content: Text(content),
            actions:
                actions.map((action) {
                  return CupertinoDialogAction(
                    isDefaultAction: action.isDefaultAction,
                    isDestructiveAction: action.isDestructiveAction,
                    onPressed: action.onPressed,
                    child: action.child,
                  );
                }).toList(),
          ),
    );
  }
}

/// Model for each action in the Cupertino dialog
class CupertinoDialogActionModel {
  final VoidCallback onPressed;
  final Widget child;
  final bool isDestructiveAction;
  final bool isDefaultAction;

  CupertinoDialogActionModel({
    required this.onPressed,
    required this.child,
    this.isDestructiveAction = false,
    this.isDefaultAction = false,
  });
}



class CupertinoConfirmDialog {
  static Future<bool> show({
    required BuildContext context,
    required String title,

    /// Use either message OR contentWidget
    String? message,
    Widget? contentWidget,

    String confirmText = "Confirm",
    String cancelText = "Cancel",
    bool isDestructive = false,
  }) async {
    final result = await showCupertinoDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return CupertinoAlertDialog(
          title: Text(title),
          content: contentWidget ??
              (message != null
                  ? Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(message),
                    )
                  : null),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(cancelText),
            ),
            CupertinoDialogAction(
              isDestructiveAction: isDestructive,
              isDefaultAction: !isDestructive,
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(confirmText),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }
}
