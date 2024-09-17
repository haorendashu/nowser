import 'package:flutter/material.dart';
import 'package:nowser/component/auth_dialog/auth_app_connect_dialog.dart';
import 'package:nowser/component/auth_dialog/auth_dialog.dart';
import 'package:nowser/component/auth_dialog/auth_dialog_base_componnet.dart';
import 'package:nowser/component/webview/web_info.dart';
import 'package:nowser/const/base.dart';
import 'package:nowser/main.dart';
import 'package:nowser/router/web_url_input/web_url_input_router.dart';

import '../../const/router_path.dart';
import '../../util/router_util.dart';
import 'webview_number_component.dart';

class WebHomeComponent extends StatefulWidget {
  WebInfo webInfo;

  WebHomeComponent(this.webInfo);

  @override
  State<StatefulWidget> createState() {
    return _WebHomeComponent();
  }
}

class _WebHomeComponent extends State<WebHomeComponent> {
  TextEditingController textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Base.BASE_PADDING),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: Hero(
                tag: "urlInput",
                child: Material(
                  child: TextField(
                    controller: textEditingController,
                    decoration:
                        const InputDecoration(border: OutlineInputBorder()),
                    readOnly: true,
                    onTap: () async {
                      var value = await RouterUtil.router(
                          context, RouterPath.WEB_URL_INPUT);
                      if (value != null &&
                          value is String &&
                          value.startsWith("http")) {
                        widget.webInfo.url = value;
                        widget.webInfo.title = null;

                        webProvider.updateWebInfo(widget.webInfo);
                      }
                    },
                  ),
                ),
              ),
            ),
          ),
          Container(
            height: 60,
            child: Row(
              children: [
                wrapBottomBtn(
                    Container(
                      alignment: Alignment.center,
                      child: WebViewNumberComponent(),
                    ), onTap: () {
                  RouterUtil.router(context, RouterPath.WEB_TABS);
                }),
                // wrapBottomBtn(const Icon(Icons.space_dashboard), onTap: () {
                //   // AuthDialog.show(context);
                //   // AuthAppConnectDialog.show(context);
                // }),
                wrapBottomBtn(const Icon(Icons.segment), onTap: () {
                  // AuthDialog.show(context);
                  RouterUtil.router(context, RouterPath.ME);
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget wrapBottomBtn(Widget btn, {Function? onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (onTap != null) {
            onTap();
          }
        },
        child: Container(
          child: btn,
        ),
      ),
    );
  }
}
