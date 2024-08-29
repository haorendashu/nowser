import 'package:flutter/material.dart';
import 'package:nowser/const/base.dart';

class MeRouterLogItemComponent extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MeRouterLogItemComponent();
  }
}

class _MeRouterLogItemComponent extends State<MeRouterLogItemComponent> {
  @override
  Widget build(BuildContext context) {
    var appNameWidget = Container(
      constraints: BoxConstraints(maxWidth: 80),
      margin: EdgeInsets.only(
        left: Base.BASE_PADDING_HALF,
        right: Base.BASE_PADDING,
      ),
      child: Text(
        "APP Name APP Name",
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );

    var logWidget = Expanded(
        child: Container(
      child: Text(
        "Log Log Log Log Log Log Log Log Log Log Log Log Log Log Log Log",
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    ));

    var rightIconWidget = Container(
      child: Icon(Icons.chevron_right),
    );

    return Container(
      child: Row(
        children: [
          appNameWidget,
          logWidget,
          rightIconWidget,
        ],
      ),
    );
  }
}
