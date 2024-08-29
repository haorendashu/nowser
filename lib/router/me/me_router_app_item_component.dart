import 'package:flutter/material.dart';
import 'package:nowser/component/app/app_type_component.dart';
import 'package:nowser/const/app_type.dart';

import '../../const/base.dart';

class MeRouterAppItemComponent extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MeRouterAppItemComponent();
  }
}

class _MeRouterAppItemComponent extends State<MeRouterAppItemComponent> {
  @override
  Widget build(BuildContext context) {
    var imageWidget = Container(
      margin: EdgeInsets.only(
        left: Base.BASE_PADDING_HALF,
        right: Base.BASE_PADDING,
      ),
      child: Icon(Icons.image),
    );

    var titleWidget = Container(
      margin: EdgeInsets.only(right: Base.BASE_PADDING),
      child: Text("Title APP"),
    );

    var typeWidget = Container(
      child: AppTypeComponent(AppType.WEB),
    );

    var rightIconWidget = Container(
      child: Icon(Icons.chevron_right),
    );

    return Container(
      child: Row(
        children: [
          imageWidget,
          titleWidget,
          typeWidget,
          Expanded(child: Container()),
          rightIconWidget,
        ],
      ),
    );
  }
}
