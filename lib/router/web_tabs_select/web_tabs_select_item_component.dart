import 'package:flutter/material.dart';
import 'package:nostr_sdk/utils/string_util.dart';
import 'package:nowser/component/image_component.dart';
import 'package:nowser/component/webview/web_info.dart';
import 'package:nowser/const/base.dart';

class WebTabsSelectItemComponent extends StatefulWidget {
  WebInfo webInfo;

  WebTabsSelectItemComponent(this.webInfo);

  @override
  State<StatefulWidget> createState() {
    return _WebTabsSelectItemComponent();
  }
}

class _WebTabsSelectItemComponent extends State<WebTabsSelectItemComponent> {
  @override
  void initState() {
    loadFavicon();
  }

  Future<void> loadFavicon() async {
    if (widget.webInfo.controller != null) {
      var favicons = await widget.webInfo.controller!.getFavicons();
      if (favicons.isNotEmpty) {
        setState(() {
          faviconUrl = favicons.first.url.toString();
        });
      }
    }
  }

  String? faviconUrl;

  double logoWidth = 30;

  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);

    Widget logoWidget;
    if (StringUtil.isNotBlank(faviconUrl)) {
      print(faviconUrl);
      logoWidget = Container(
        width: logoWidth,
        height: logoWidth,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(logoWidth / 2),
          color: themeData.hintColor,
        ),
        child: ImageComponent(
          imageUrl: faviconUrl!,
          width: logoWidth,
          height: logoWidth,
        ),
      );
    } else {
      logoWidget = Icon(
        Icons.image,
        size: logoWidth,
      );
    }

    var title = widget.webInfo.title;
    if (StringUtil.isBlank(title)) {
      title = widget.webInfo.url;
    }

    Widget removeIcon = GestureDetector(
      child: Icon(Icons.close),
    );

    var list = [
      Container(
        margin: const EdgeInsets.only(right: Base.BASE_PADDING_HALF),
        child: logoWidget,
      ),
      Expanded(
          child: Container(
        child: Text(
          title!,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      )),
      Container(
        margin: EdgeInsets.only(left: Base.BASE_PADDING_HALF),
        child: removeIcon,
      ),
    ];

    return Container(
      padding: EdgeInsets.only(
        left: Base.BASE_PADDING,
        right: Base.BASE_PADDING,
        top: Base.BASE_PADDING_HALF,
        bottom: Base.BASE_PADDING_HALF,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      child: Row(
        children: list,
      ),
    );
  }
}
