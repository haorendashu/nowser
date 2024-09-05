import 'package:flutter/material.dart';
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
          autofocus: true,
          onSubmitted: (value) {
            RouterUtil.back(context, value);
          },
        ),
      ),
    );

    list.add(Expanded(child: Container()));
    list.add(Container(
      padding: const EdgeInsets.all(Base.BASE_PADDING),
      child: inputWidget,
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
