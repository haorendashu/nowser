import 'package:flutter/material.dart';

import '../const/base.dart';

class TagComponent extends StatefulWidget {
  String text;

  TagComponent(this.text);

  @override
  State<StatefulWidget> createState() {
    return _TagComponent();
  }
}

class _TagComponent extends State<TagComponent> {
  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: themeData.hintColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.only(
        left: Base.BASE_PADDING_HALF,
        right: Base.BASE_PADDING_HALF,
        top: 4,
        bottom: 4,
      ),
      child: Text(
        widget.text,
        style: TextStyle(
          fontSize: themeData.textTheme.bodySmall!.fontSize,
          color: themeData.hintColor,
        ),
      ),
    );
  }
}
