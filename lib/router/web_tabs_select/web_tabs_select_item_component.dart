import 'package:flutter/material.dart';
import 'package:nostr_sdk/utils/string_util.dart';
import 'package:nowser/component/image_component.dart';
import 'package:nowser/component/webview/web_info.dart';
import 'package:nowser/const/base.dart';
import 'package:nowser/main.dart';
import 'package:nowser/util/router_util.dart';

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
      var favicon = await widget.webInfo.controller!.getFavicon();
      if (StringUtil.isNotBlank(favicon)) {
        setState(() {
          faviconUrl = favicon;
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
      logoWidget = Container(
        width: logoWidth,
        height: logoWidth,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(logoWidth / 2),
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
      onTap: () {
        webProvider.closeTab(widget.webInfo);
        RouterUtil.back(context);
      },
      behavior: HitTestBehavior.translucent,
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
        color: themeData.cardColor,
      ),
      child: Row(
        children: list,
      ),
    );
  }
}
