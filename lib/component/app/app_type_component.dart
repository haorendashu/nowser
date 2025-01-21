import 'package:flutter/material.dart';
import 'package:nowser/const/app_type.dart';

import '../../generated/l10n.dart';
import '../tag_component.dart';

class AppTypeComponent extends StatefulWidget {
  int appType;

  AppTypeComponent(this.appType);

  @override
  State<StatefulWidget> createState() {
    return _AppTypeComponent();
  }
}

class _AppTypeComponent extends State<AppTypeComponent> {
  late S s;

  @override
  Widget build(BuildContext context) {
    String typeName = s.WEB;
    if (widget.appType == AppType.ANDROID_APP) {
      typeName = s.Android;
    } else if (widget.appType == AppType.REMOTE) {
      typeName = s.Remote;
    }

    return TagComponent(typeName);
  }
}
