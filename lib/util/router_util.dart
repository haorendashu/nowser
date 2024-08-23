import 'dart:async';

import 'package:flutter/material.dart';

class RouterUtil {
  static Future<T?> router<T>(BuildContext context, String pageName,
      [Object? arguments]) async {
    return Navigator.of(context).pushNamed<T>(pageName, arguments: arguments);
  }

  static Future<T?> push<T extends Object?>(
      BuildContext context, MaterialPageRoute<T> route) {
    return Navigator.of(context).push(route);
  }

  static Object? routerArgs(BuildContext context) {
    RouteSettings? setting = ModalRoute.of(context)?.settings;
    return setting?.arguments;
  }

  static void back(BuildContext context, [Object? returnObj]) {
    NavigatorState ns = Navigator.of(context);
    if (ns.canPop()) {
      ns.pop(returnObj);
    }
  }
}
