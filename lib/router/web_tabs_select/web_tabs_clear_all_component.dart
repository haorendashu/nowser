import 'package:flutter/material.dart';

class WebTabsClearAllComponent extends StatefulWidget {
  Function clearAll;

  WebTabsClearAllComponent(this.clearAll);

  @override
  State<StatefulWidget> createState() {
    return _WebTabsClearAllComponent();
  }
}

class _WebTabsClearAllComponent extends State<WebTabsClearAllComponent> {
  bool firstClick = false;

  @override
  Widget build(BuildContext context) {
    Widget iconWidget = Icon(
      Icons.delete,
      size: 30,
    );

    if (firstClick) {
      iconWidget = Row(
        mainAxisSize: MainAxisSize.min,
        children: [iconWidget, Text("Clear all")],
      );
    }

    return GestureDetector(
      onTap: () {
        if (firstClick) {
          widget.clearAll();
        } else {
          setState(() {
            firstClick = true;
          });
        }
      },
      child: iconWidget,
    );
  }
}
