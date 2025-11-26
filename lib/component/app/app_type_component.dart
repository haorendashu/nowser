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
  @override
  Widget build(BuildContext context) {
    var s = S.of(context);

    String typeName = s.WEB;
    if (widget.appType == AppType.ANDROID_APP) {
      typeName = s.Android;
    } else if (widget.appType == AppType.REMOTE) {
      typeName = s.Remote;
    } else if (widget.appType == AppType.URI) {
      typeName = s.Uri;
    }

    return TagComponent(typeName);
  }
}
