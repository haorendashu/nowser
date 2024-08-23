import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/web_provider.dart';

class WebViewNumberComponent extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _WebViewNumberComponent();
  }
}

class _WebViewNumberComponent extends State<WebViewNumberComponent> {
  @override
  Widget build(BuildContext context) {
    return Selector<WebProvider, int>(builder: (context, length, child) {
      return Badge(
        label: Text("$length"),
        backgroundColor:
            Colors.blueAccent, // TODO here should use background color
        child: Icon(Icons.crop_din),
      );
    }, selector: (context, provider) {
      return provider.webInfos.length;
    });
  }
}
