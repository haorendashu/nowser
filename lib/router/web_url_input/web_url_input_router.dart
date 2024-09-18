import 'package:flutter/material.dart';
import 'package:nostr_sdk/utils/string_util.dart';
import 'package:nowser/component/qrscanner.dart';
import 'package:nowser/util/router_util.dart';

import '../../const/base.dart';

class WebUrlInputRouter extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _WebUrlInputRouter();
  }
}

class _WebUrlInputRouter extends State<WebUrlInputRouter> {
  TextEditingController textEditingController = TextEditingController();

  String? url;

  late FocusNode focusNode;

  @override
  void initState() {
    super.initState();
    focusNode = FocusNode();
    Future.delayed(const Duration(milliseconds: 350), () {
      focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (url == null) {
      var arg = RouterUtil.routerArgs(context);
      if (arg != null && arg is String) {
        url = arg;
        textEditingController.text = arg;
      }
    }

    List<Widget> list = [];

    var inputWidget = Hero(
      tag: "urlInput",
      child: Material(
        child: TextField(
          controller: textEditingController,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          focusNode: focusNode,
          onSubmitted: (value) {
            RouterUtil.back(context, value);
          },
        ),
      ),
    );

    list.add(Expanded(child: Container()));
    list.add(Container(
      padding: const EdgeInsets.all(Base.BASE_PADDING),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              RouterUtil.back(context);
            },
            behavior: HitTestBehavior.translucent,
            child: Container(
              padding: EdgeInsets.only(right: Base.BASE_PADDING),
              child: Icon(Icons.chevron_left),
            ),
          ),
          Expanded(child: inputWidget),
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            child: Container(
              padding: const EdgeInsets.only(left: Base.BASE_PADDING),
              child: GestureDetector(
                onTap: () async {
                  var url = await QRScanner.show(context);
                  if (StringUtil.isNotBlank(url) && url!.startsWith("http")) {
                    RouterUtil.back(context, url);
                  }
                },
                child: Icon(Icons.qr_code_scanner),
              ),
            ),
          ),
        ],
      ),
    ));

    return Scaffold(
      body: Container(
        child: Column(
          children: list,
        ),
      ),
    );
  }
}
