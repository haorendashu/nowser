import 'package:flutter/material.dart';
import 'package:nowser/const/base.dart';
import 'package:nowser/data/bookmark.dart';
import 'package:nowser/main.dart';

import '../image_component.dart';

class WebHomeBtnComponent extends StatefulWidget {
  Bookmark bookmark;

  WebHomeBtnComponent(this.bookmark);

  @override
  State<StatefulWidget> createState() {
    return _WebHomeBtnComponent();
  }
}

class _WebHomeBtnComponent extends State<WebHomeBtnComponent> {
  static const double imageWidth = 40;

  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);
    var cardColor = themeData.cardColor;

    Widget iconWidget = Icon(
      Icons.image,
      weight: 60,
    );
    if (widget.bookmark.favicon != null) {
      iconWidget = ImageComponent(
        imageUrl: widget.bookmark.favicon!,
        width: 36,
        height: 36,
        fit: BoxFit.cover,
      );
    }

    return GestureDetector(
      onTap: () {
        if (widget.bookmark.url != null) {
          webProvider.addTab(url: widget.bookmark.url!);
        }
      },
      child: Container(
        width: imageWidth + Base.BASE_PADDING_HALF * 2,
        height: 68,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: imageWidth,
              height: imageWidth,
              padding: const EdgeInsets.all(Base.BASE_PADDING_HALF),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(Base.BASE_PADDING),
              ),
              child: iconWidget,
            ),
            Container(
              margin: EdgeInsets.only(top: Base.BASE_PADDING_HALF),
              child: Text(
                widget.bookmark.title!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: themeData.textTheme.bodySmall!.fontSize,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
