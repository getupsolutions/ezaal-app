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
