import 'package:flutter/material.dart';
import 'package:nowser/const/base.dart';

class MeRouterWebItemComponent extends StatefulWidget {
  int num;

  String name;

  IconData iconData;

  MeRouterWebItemComponent({
    required this.num,
    required this.name,
    required this.iconData,
  });

  @override
  State<StatefulWidget> createState() {
    return _MeRouterWebItemComponent();
  }
}

class _MeRouterWebItemComponent extends State<MeRouterWebItemComponent> {
  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);
    var cardColor = themeData.cardColor;

    return Container(
      alignment: Alignment.center,
      // margin: widget.margin,
      child: Container(
        width: 80,
        padding: const EdgeInsets.only(
          left: Base.BASE_PADDING,
          right: Base.BASE_PADDING,
          top: Base.BASE_PADDING,
          bottom: Base.BASE_PADDING,
        ),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(Base.BASE_PADDING),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(widget.iconData),
            Text(
              widget.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: themeData.textTheme.bodySmall!.fontSize! - 2,
              ),
            ),
            Text(
              "${widget.num}",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
