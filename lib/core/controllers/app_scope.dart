import 'package:flutter/widgets.dart';

import 'app_controllers.dart';

class AppScope extends InheritedWidget {
  const AppScope({super.key, required this.controllers, required super.child});

  final AppControllers controllers;

  static AppControllers of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope not found');
    return scope!.controllers;
  }

  @override
  bool updateShouldNotify(covariant AppScope oldWidget) => controllers != oldWidget.controllers;
}
