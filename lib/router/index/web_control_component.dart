import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:nowser/const/base.dart';
import 'package:nowser/const/router_path.dart';
import 'package:nowser/provider/web_provider.dart';
import 'package:nowser/router/index/web_control_btn_component.dart';
import 'package:nowser/util/router_util.dart';
import 'package:provider/provider.dart';

class WebControlComponent extends StatefulWidget {
  Function closeControl;

  WebControlComponent(this.closeControl);

  @override
  State<StatefulWidget> createState() {
    return _WebControlComponent();
  }
}

class _WebControlComponent extends State<WebControlComponent> {
  @override
  Widget build(BuildContext context) {
    var webProvider = Provider.of<WebProvider>(context);
    var webInfo = webProvider.currentWebInfo;

    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.only(
              left: Base.BASE_PADDING,
              right: Base.BASE_PADDING,
            ),
            child: Row(
              children: [
                Expanded(
                  child: WebControlBtnComponent(
                    name: "Back",
                    icon: Icon(
                      Icons.chevron_left,
                      size: 30,
                    ),
                    onTap: () {
                      webProvider.back(context);
                    },
                  ),
                ),
                Expanded(
                  child: WebControlBtnComponent(
                    name: "Forward",
                    icon: Icon(
                      Icons.chevron_right,
                      size: 30,
                    ),
                    onTap: () {
                      webProvider.forward(context);
                    },
                  ),
                ),
                Expanded(
                  child: WebControlBtnComponent(
                    name: "Refresh",
                    icon: Icon(
                      Icons.refresh,
                      size: 30,
                    ),
                    onTap: () {
                      webProvider.refresh(context);
                      widget.closeControl();
                    },
                  ),
                ),
                Expanded(
                  child: WebControlBtnComponent(
                    name: "Stealth",
                    icon: Icon(
                      Icons.disabled_visible_outlined,
                      size: 30,
                    ),
                    onTap: () {
                      BotToast.showText(text: "Coming...");
                    },
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(Base.BASE_PADDING),
            child: Row(
              children: [
                Expanded(
                  child: WebControlBtnComponent(
                    name: "Bookmarks",
                    icon: Icon(
                      Icons.bookmark_border,
                      size: 30,
                    ),
                    onTap: () async {
                      var url =
                          await RouterUtil.router(context, RouterPath.BOOKMARK);
                      if (webProvider.currentGoTo(url)) {
                        widget.closeControl();
                      }
                    },
                  ),
                ),
                Expanded(
                  child: WebControlBtnComponent(
                    name: "Stars",
                    icon: Icon(
                      Icons.bookmark_add_outlined,
                      size: 30,
                    ),
                    onTap: () {
                      var webInfo = webProvider.currentWebInfo();
                      if (webInfo != null) {
                        webProvider.addBookmark(context, webInfo);
                        widget.closeControl();
                      }
                    },
                  ),
                ),
                Expanded(
                  child: WebControlBtnComponent(
                    name: "Historys",
                    icon: Icon(
                      Icons.history,
                      size: 30,
                    ),
                    onTap: () async {
                      var url =
                          await RouterUtil.router(context, RouterPath.HISTORY);
                      if (webProvider.currentGoTo(url)) {
                        widget.closeControl();
                      }
                    },
                  ),
                ),
                Expanded(
                  child: WebControlBtnComponent(
                    name: "Downloads",
                    icon: Icon(
                      Icons.download,
                      size: 30,
                    ),
                    onTap: () {
                      BotToast.showText(text: "Coming...");
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
