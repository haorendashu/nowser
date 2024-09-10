import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ReloadInheritedWidget extends InheritedWidget {
  Function reload;

  ReloadInheritedWidget({
    required super.child,
    required this.reload,
  });

  static ReloadInheritedWidget? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ReloadInheritedWidget>();
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return false;
  }
}
