import 'package:flutter/material.dart';
import 'package:nowser/component/webview/web_info.dart';
import 'package:nowser/const/base.dart';
import 'package:nowser/main.dart';

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
      child: Center(
        child: TextField(
          controller: textEditingController,
          decoration: InputDecoration(border: OutlineInputBorder()),
          onSubmitted: (value) {
            print("onSubmitted $value");
            if (value.startsWith("http")) {
              widget.webInfo.url = value;
              widget.webInfo.title = null;

              webProvider.updateWebInfo(widget.webInfo);
            }
          },
        ),
      ),
    );
  }
}
