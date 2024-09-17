import 'package:flutter/material.dart';

class WebControlBtnComponent extends StatefulWidget {
  String name;

  Widget icon;

  Function? onTap;

  WebControlBtnComponent({
    required this.name,
    required this.icon,
    this.onTap,
  });

  @override
  State<StatefulWidget> createState() {
    return _WebControlBtnComponent();
  }
}

class _WebControlBtnComponent extends State<WebControlBtnComponent> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.onTap != null) {
          widget.onTap!();
        }
      },
      behavior: HitTestBehavior.translucent,
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            widget.icon,
            Text(widget.name),
          ],
        ),
      ),
    );
  }
}
