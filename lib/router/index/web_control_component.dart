import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:nowser/const/base.dart';
import 'package:nowser/const/router_path.dart';
import 'package:nowser/main.dart';
import 'package:nowser/provider/web_provider.dart';
import 'package:nowser/router/index/web_control_btn_component.dart';
import 'package:nowser/util/router_util.dart';
import 'package:provider/provider.dart';

import '../../generated/l10n.dart';

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
    var s = S.of(context);
    var webProvider = Provider.of<WebProvider>(context);
    var webInfo = webProvider.currentWebInfo();
    var themeData = Theme.of(context);
    Color mainColor = themeData.colorScheme.primary;

    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.only(
              left: Base.BASE_PADDING,
              right: Base.BASE_PADDING,
            ),
            child: Row(
              children: [
                Expanded(
                  child: WebControlBtnComponent(
                    name: s.Back,
                    icon: const Icon(
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
                    name: s.Forward,
                    icon: const Icon(
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
                    name: s.Refresh,
                    icon: const Icon(
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
                    name: s.Incognito,
                    icon: Icon(
                      Icons.disabled_visible_outlined,
                      size: 30,
                      color: webInfo?.incognitoMode == true ? mainColor : null,
                    ),
                    onTap: () {
                      webProvider.setIcognitoMode();
                      widget.closeControl();
                    },
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(Base.BASE_PADDING),
            child: Row(
              children: [
                Expanded(
                  child: WebControlBtnComponent(
                    name: s.Bookmarks,
                    icon: const Icon(
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
                    name: s.Stars,
                    icon: const Icon(
                      Icons.bookmark_add_outlined,
                      size: 30,
                    ),
                    onTap: () {
                      var webInfo = webProvider.currentWebInfo();
                      if (webInfo != null) {
                        bookmarkProvider.addBookmark(context, webInfo);
                        widget.closeControl();
                      }
                    },
                  ),
                ),
                Expanded(
                  child: WebControlBtnComponent(
                    name: s.Historys,
                    icon: const Icon(
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
                    name: s.Downloads,
                    icon: const Icon(
                      Icons.download,
                      size: 30,
                    ),
                    onTap: () {
                      BotToast.showText(text: s.Comming_soon);
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
