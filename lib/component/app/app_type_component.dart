import 'package:flutter/material.dart';
import 'package:nowser/const/app_type.dart';

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
  @override
  Widget build(BuildContext context) {
    String typeName = "WEB";
    if (widget.appType == AppType.ANDROID_APP) {
      typeName = "Android";
    } else if (widget.appType == AppType.REMOTE) {
      typeName = "Remote";
    }

    return TagComponent(typeName);
  }
}
