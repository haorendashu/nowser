import 'package:flutter/material.dart';

import '../../const/base.dart';

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
    var themeData = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: themeData.hintColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: EdgeInsets.only(
        left: Base.BASE_PADDING_HALF,
        right: Base.BASE_PADDING_HALF,
        top: 4,
        bottom: 4,
      ),
      child: Text(
        "WEB",
        style: TextStyle(
          fontSize: themeData.textTheme.bodySmall!.fontSize,
          color: themeData.hintColor,
        ),
      ),
    );
  }
}