import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:nostr_sdk/utils/platform_util.dart';
import 'package:nostr_sdk/utils/string_util.dart';
import 'package:nowser/const/base_consts.dart';
import 'package:nowser/data/bookmark.dart';
import 'package:nowser/data/bookmark_db.dart';
import 'package:quick_actions/quick_actions.dart';

import '../const/base.dart';
import '../main.dart';
import '../util/router_util.dart';
import '../util/table_mode_util.dart';
import '../util/theme_util.dart';

class BookmarkEditDialog extends StatefulWidget {
  Bookmark bookmark;

  BookmarkEditDialog(this.bookmark);

  static Future<void> show(BuildContext context, Bookmark bookmark) async {
    await showDialog<String>(
      context: context,
      builder: (_context) {
        return BookmarkEditDialog(bookmark);
      },
    );
  }

  @override
  State<StatefulWidget> createState() {
    return _BookmarkEditDialog();
  }
}

class _BookmarkEditDialog extends State<BookmarkEditDialog> {
  TextEditingController nameTextController = TextEditingController();

  TextEditingController urlTextController = TextEditingController();

  bool addedToIndex = false;

  bool addedToQa = false;

  @override
  void initState() {
    super.initState();

    if (StringUtil.isNotBlank(widget.bookmark.title)) {
      nameTextController.text = widget.bookmark.title!;
    }
    if (StringUtil.isNotBlank(widget.bookmark.url)) {
      urlTextController.text = widget.bookmark.url!;
    }

    if (widget.bookmark.addedToIndex == OpenStatus.OPEN) {
      addedToIndex = true;
    }
    if (widget.bookmark.addedToQa == OpenStatus.OPEN) {
      addedToQa = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);

    List<Widget> list = [];
    list.add(Container(
      margin: EdgeInsets.only(
        bottom: Base.BASE_PADDING,
      ),
      child: Text(
        "Add bookmark",
        style: TextStyle(
          fontSize: themeData.textTheme.bodyLarge!.fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
    ));

    list.add(Container(
      child: TextField(
        controller: nameTextController,
        decoration: InputDecoration(
          labelText: "Name",
        ),
      ),
    ));

    list.add(Container(
      child: TextField(
        controller: urlTextController,
        decoration: InputDecoration(
          labelText: "Url",
        ),
      ),
    ));

    list.add(Container(
      margin: EdgeInsets.only(top: Base.BASE_PADDING_HALF),
      child: Row(
        children: [
          Text("Add to index"),
          Expanded(
            child: Checkbox(
              value: addedToIndex,
              onChanged: (v) {
                if (v != null) {
                  setState(() {
                    addedToIndex = v;
                  });
                }
              },
            ),
          )
        ],
      ),
    ));

    list.add(Container(
      child: Row(
        children: [
          Text("Add to quick action"),
          Expanded(
            child: Checkbox(
              value: addedToQa,
              onChanged: (v) {
                if (v != null) {
                  setState(() {
                    addedToQa = v;
                  });
                }
              },
            ),
          )
        ],
      ),
    ));

    list.add(Container(
      margin: EdgeInsets.only(
        top: Base.BASE_PADDING * 2,
        bottom: Base.BASE_PADDING,
      ),
      width: double.infinity,
      child: FilledButton(onPressed: confirm, child: Text("Confirm")),
    ));

    Widget main = Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: list,
      ),
    );
    if (PlatformUtil.isPC() || TableModeUtil.isTableMode()) {
      main = Container(
        width: mediaDataCache.size.width / 2,
        child: main,
      );
    }

    return Dialog(
      child: Container(
        padding: EdgeInsets.all(Base.BASE_PADDING * 2),
        child: main,
      ),
    );
  }

  Future<void> confirm() async {
    var title = nameTextController.text;
    var url = urlTextController.text;

    var bookmark = Bookmark(
      title: title,
      url: url,
      id: widget.bookmark.id,
      favicon: widget.bookmark.favicon,
      weight: widget.bookmark.weight,
      createdAt: widget.bookmark.createdAt,
      addedToIndex: addedToIndex ? 1 : -1,
      addedToQa: addedToQa ? 1 : -1,
    );

    if (StringUtil.isBlank(bookmark.title) ||
        StringUtil.isBlank(bookmark.url)) {
      BotToast.showText(text: "Input can't be null");
      return;
    }

    if (bookmark.id == null) {
      await BookmarkDB.insert(bookmark);
    } else {
      await BookmarkDB.update(bookmark);
    }

    try {
      var allQas = await BookmarkDB.allQas();
      List<ShortcutItem> qas = [];
      for (var bk in allQas) {
        if (StringUtil.isBlank(bk.title) || StringUtil.isBlank(bk.url)) {
          continue;
        }

        qas.add(ShortcutItem(
            type: bk.url!, localizedTitle: bk.title!, icon: 'ic_launcher'));
        quickActions.setShortcutItems(qas);
      }
    } catch (e) {
      print(e);
    }

    await bookmarkProvider.reload();
    RouterUtil.back(context);
  }
}
