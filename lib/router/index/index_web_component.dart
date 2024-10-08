import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:nostr_sdk/utils/string_util.dart';
import 'package:nowser/component/webview/web_info.dart';
import 'package:nowser/component/webview/webview_component.dart';
import 'package:nowser/const/base.dart';
import 'package:nowser/const/router_path.dart';
import 'package:nowser/main.dart';
import 'package:nowser/provider/web_provider.dart';
import 'package:nowser/util/router_util.dart';
import 'package:provider/provider.dart';

import '../../component/webview/web_home_component.dart';
import '../../component/webview/webview_number_component.dart';
import 'web_control_component.dart';

class IndexWebComponent extends StatefulWidget {
  WebInfo webInfo;

  Function showControl;

  IndexWebComponent(this.webInfo, this.showControl, {required GlobalKey key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _IndexWebComponent();
  }
}

class _IndexWebComponent extends State<IndexWebComponent> {
  static const double BOTTOM_BTN_PADDING = 10;

  @override
  void initState() {
    super.initState();
    // print("indexWebComp initState ${widget.webInfo.id}");
  }

  @override
  void dispose() {
    super.dispose();
    // print("indexWebComp dispose ${widget.webInfo.id}");
  }

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);
    var padding = mediaQuery.padding;
    var maxWidth = mediaQuery.size.width;
    var titleWidth = maxWidth / 2;

    Widget numberWidget = WebViewNumberComponent();
    var webInfo = widget.webInfo;

    if (StringUtil.isBlank(webInfo.url)) {
      return WebHomeComponent(webInfo);
    }

    var webComp = WebViewComponent(
        webInfo,
        (webInfo, controller) {
          webInfo.controller = controller;
          webProvider.updateWebInfo(webInfo);
        },
        onTitleChanged,
        (webInfo, controller) {
          webInfo.controller = controller;
          webProvider.onLoadStop(webInfo);
        });

    String title = "";
    if (StringUtil.isNotBlank(webInfo.title)) {
      title = webInfo.title!;
    } else if (StringUtil.isNotBlank(webInfo.url)) {
      title = webInfo.url;
    }

    var main = Column(
      children: [
        Expanded(child: webComp),
        Container(
          height: 60,
          child: Row(
            children: [
              wrapBottomBtn(const Icon(Icons.home_filled), left: 13, right: 8,
                  onTap: () {
                webProvider.goHome(webInfo);
              }),
              wrapBottomBtn(numberWidget, left: 8, right: 8, onTap: () {
                RouterUtil.router(context, RouterPath.WEB_TABS);
              }),
              Expanded(
                child: Hero(
                  tag: "urlInput",
                  child: Material(
                    child: GestureDetector(
                      onTap: () async {
                        if (webInfo.controller == null) {
                          return;
                        }

                        var url = await webInfo.controller!.getUrl();
                        var value = await RouterUtil.router(
                            context, RouterPath.WEB_URL_INPUT, url.toString());
                        if (value != null && value is String) {
                          webProvider.goTo(webInfo, value);
                        }
                      },
                      behavior: HitTestBehavior.translucent,
                      child: Container(
                        margin: const EdgeInsets.only(
                          left: 8,
                          right: 8,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(),
                          borderRadius:
                              BorderRadius.circular(Base.BASE_PADDING_HALF),
                        ),
                        padding: const EdgeInsets.only(
                          left: Base.BASE_PADDING,
                          right: Base.BASE_PADDING,
                          top: Base.BASE_PADDING_HALF,
                          bottom: Base.BASE_PADDING_HALF,
                        ),
                        width: titleWidth,
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              wrapBottomBtn(const Icon(Icons.space_dashboard), onTap: () {
                widget.showControl();
              }, left: 8, right: 8),
              wrapBottomBtn(const Icon(Icons.segment), left: 8, right: 13,
                  onTap: () {
                RouterUtil.router(context, RouterPath.ME);
              }),
            ],
          ),
        ),
      ],
    );

    return Container(
      padding: EdgeInsets.only(
        top: padding.top,
        bottom: padding.bottom,
      ),
      child: main,
    );
  }

  void onTitleChanged(
      WebInfo webInfo, InAppWebViewController controller, String? title) {
    webInfo.controller = controller;
    webInfo.title = title;
    webProvider.updateWebInfo(webInfo);
    setState(() {});
  }

  Widget wrapBottomBtn(Widget btn,
      {double left = 10, double right = 10, Function? onTap}) {
    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          onTap();
        }
      },
      child: Container(
        padding: EdgeInsets.only(
          left: left,
          right: right,
        ),
        child: btn,
      ),
    );
  }
}
