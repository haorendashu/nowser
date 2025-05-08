import 'package:flutter/material.dart';
import 'package:nowser/component/image_component.dart';
import 'package:nowser/const/base.dart';

class UrlListItemComponnet extends StatefulWidget {
  String? image;

  String title;

  String url;

  int? dateTime;

  UrlListItemComponnet({
    this.image,
    required this.title,
    required this.url,
    this.dateTime,
  });

  @override
  State<StatefulWidget> createState() {
    return _UrlListItemComponnet();
  }
}

class _UrlListItemComponnet extends State<UrlListItemComponnet> {
  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);
    var smallFontSize = themeData.textTheme.bodySmall!.fontSize;

    List<Widget> list = [];

    Widget iconWidget = Icon(
      Icons.image,
      weight: 60,
    );
    if (widget.image != null) {
      iconWidget = ImageComponent(
        imageUrl: widget.image!,
        width: 36,
        height: 36,
        fit: BoxFit.cover,
      );
    }

    list.add(Container(
      width: 60,
      height: 60,
      alignment: Alignment.center,
      child: iconWidget,
    ));

    String host = widget.url;
    try {
      var uri = Uri.parse(widget.url);
      host = uri.host;
    } catch (e) {}

    String time = "";
    if (widget.dateTime != null) {
      var dt = DateTime.fromMillisecondsSinceEpoch(widget.dateTime! * 1000);
      time = "${dt.hour}:${dt.minute}";
    }

    list.add(Expanded(
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
                width: 1, color: themeData.hintColor.withOpacity(0.5)),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Container(
                margin: EdgeInsets.only(
                  top: Base.BASE_PADDING_HALF,
                  bottom: Base.BASE_PADDING_HALF,
                ),
                padding: EdgeInsets.only(right: Base.BASE_PADDING_HALF),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      host,
                      style: TextStyle(
                        fontSize: smallFontSize,
                        color: themeData.hintColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              child: Text(
                time,
                style: TextStyle(
                  color: themeData.hintColor,
                ),
              ),
            ),
          ],
        ),
      ),
    ));

    return Container(
      padding: EdgeInsets.only(
        left: Base.BASE_PADDING,
        right: Base.BASE_PADDING,
      ),
      child: Row(
        children: list,
      ),
    );
  }
}
