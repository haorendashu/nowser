import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nostr_sdk/utils/string_util.dart';
import 'package:nowser/main.dart';

import '../../const/base.dart';
import '../../generated/l10n.dart';
import '../../util/router_util.dart';
import '../../util/theme_util.dart';

class LongPressDialog extends StatefulWidget {
  static const int TYPE_URL = 0;

  static const int TYPE_IMAGE = 1;

  int infoType;

  Map<String, dynamic> info;

  LongPressDialog(this.infoType, this.info);

  static Future<void> show(
      BuildContext context, int infoType, Map<String, dynamic> info) {
    return showDialog(
      context: context,
      builder: (context) {
        return LongPressDialog(
          infoType,
          info,
        );
      },
    );
  }

  @override
  State<StatefulWidget> createState() {
    return _LongPressDialog();
  }
}

class _LongPressDialog extends State<LongPressDialog> {
  @override
  Widget build(BuildContext context) {
    var s = S.of(context);
    var themeData = Theme.of(context);
    Color cardColor = themeData.cardColor;
    var maxHeight = MediaQuery.of(context).size.height;

    List<Widget> list = [];

    var src = widget.info["src"];
    var url = widget.info["url"];
    var title = widget.info["title"];

    if (widget.infoType == LongPressDialog.TYPE_URL) {
      if (StringUtil.isNotBlank(title)) {
        list.add(LongPressDialogItem(
          s.Copy_Title,
          onTap: () {
            _doCopy(title);
          },
        ));
      }
      if (StringUtil.isNotBlank(url)) {
        list.add(LongPressDialogItem(
          s.Copy_Link,
          onTap: () {
            _doCopy(url);
          },
        ));
        list.add(LongPressDialogItem(
          s.Open_in_a_New_Tab,
          onTap: () {
            webProvider.addTab(url: url);
          },
        ));
        list.add(LongPressDialogItem(
          s.Open_with_Stealth_Mode,
          onTap: () {
            webProvider.addTab(url: url);
          },
        ));
        list.add(LongPressDialogItem(
          s.Open_backgroundly,
          onTap: () {
            webProvider.addTab(url: url, openTab: false);
          },
          showBottomLine: false,
        ));
      }
    } else if (widget.infoType == LongPressDialog.TYPE_IMAGE &&
        StringUtil.isNotBlank(src)) {
      list.add(LongPressDialogItem(
        s.Open_image_in_a_New_Tab,
        onTap: () {
          webProvider.addTab(url: src);
        },
      ));
      list.add(LongPressDialogItem(
        s.Download_image,
        onTap: () {},
        showBottomLine: false,
      ));
    }

    Widget main = Container(
      width: double.infinity,
      padding: const EdgeInsets.only(
        left: Base.BASE_PADDING,
        right: Base.BASE_PADDING,
        top: Base.BASE_PADDING_HALF,
        bottom: Base.BASE_PADDING_HALF,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(15)),
        color: cardColor,
      ),
      constraints: BoxConstraints(
        maxHeight: maxHeight * 0.8,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: list,
        ),
      ),
    );

    return Scaffold(
      backgroundColor: ThemeUtil.getDialogCoverColor(themeData),
      body: FocusScope(
        // autofocus: true,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            RouterUtil.back(context);
          },
          child: Container(
            width: double.infinity,
            height: double.infinity,
            padding: const EdgeInsets.only(
              left: Base.BASE_PADDING,
              right: Base.BASE_PADDING,
            ),
            alignment: Alignment.center,
            child: GestureDetector(
              onTap: () {},
              child: main,
            ),
          ),
        ),
      ),
    );
  }

  void _doCopy(String text) {
    Clipboard.setData(ClipboardData(text: text));
  }
}

class LongPressDialogItem extends StatelessWidget {
  static const double HEIGHT = 44;

  String title;
  VoidCallback? onTap;
  bool showBottomLine;

  LongPressDialogItem(this.title, {this.onTap, this.showBottomLine = true});

  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);
    var dividerColor = themeData.dividerColor;

    Widget main = Container(
      padding: const EdgeInsets.only(
          left: Base.BASE_PADDING + 5, right: Base.BASE_PADDING + 5),
      child: Text(title),
    );

    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          onTap!();
        }
        RouterUtil.back(context);
      },
      child: Container(
        decoration: BoxDecoration(
          // color: color,
          border: showBottomLine
              ? Border(bottom: BorderSide(color: dividerColor))
              : null,
        ),
        alignment: Alignment.center,
        height: HEIGHT,
        child: main,
      ),
    );
  }
}
