import 'package:flutter/material.dart';

class UserPicComponent extends StatefulWidget {
  double width;

  UserPicComponent({required this.width});

  @override
  State<StatefulWidget> createState() {
    return _UserPicComponent();
  }
}

class _UserPicComponent extends State<UserPicComponent> {
  @override
  Widget build(BuildContext context) {
    Widget innerWidget = Icon(
      Icons.account_circle,
      size: widget.width,
    );

    return Container(
      width: widget.width,
      height: widget.width,
      clipBehavior: Clip.hardEdge,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.width / 2),
      ),
      child: innerWidget,
    );
  }
}
