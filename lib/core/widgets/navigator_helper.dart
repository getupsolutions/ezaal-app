import 'package:flutter/material.dart';

class NavigatorHelper {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  //Push
  static Future<T?> push<T extends Object?>(Widget page) {
    return navigatorKey.currentState!.push<T>(
      MaterialPageRoute(builder: (context) => page),
    );
  }

  //PushReplacment
  static Future<T?> pushReplacement<T extends Object?, TO extends Object?>(
    Widget page, {
    TO? result,
  }) {
    return navigatorKey.currentState!.pushReplacement<T, TO>(
      MaterialPageRoute(builder: (_) => page),
      result: result,
    );
  }

  // Pop current page
  static void pop<T extends Object?>([T? result]) {
    navigatorKey.currentState!.pop(result);
  }

  // Pop until first route
  static void popUntilFirst() {
    navigatorKey.currentState!.popUntil((route) => route.isFirst);
  }
}
