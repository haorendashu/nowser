import 'package:flutter/material.dart';
import 'package:nowser/const/base_consts.dart';
import 'package:nowser/data/bookmark.dart';
import 'package:nowser/data/bookmark_db.dart';

import '../component/bookmark_edit_dialog.dart';
import '../component/webview/web_info.dart';

class BookmarkProvider extends ChangeNotifier {
  List<Bookmark> bookmarks = [];

  Future<void> init() async {
    await _reloadData();
  }

  Future<void> _reloadData() async {
    bookmarks = await BookmarkDB.all();
  }

  Future<void> reload() async {
    await _reloadData();
    notifyListeners();
  }

  List<Bookmark> get indexBookmarks {
    List<Bookmark> list = [];
    for (var bookmark in bookmarks) {
      if (bookmark.addedToIndex == OpenStatus.OPEN) {
        list.add(bookmark);
      }
    }
    return list;
  }

  void addBookmark(BuildContext context, WebInfo webInfo) {
    if (webInfo.browserHistory == null) {
      return;
    }

    var bookmark = Bookmark();
    bookmark.title = webInfo.title;
    bookmark.url = webInfo.browserHistory!.url;
    bookmark.favicon = webInfo.browserHistory!.favicon;
    bookmark.weight = 0;
    bookmark.addedToIndex = -1;
    bookmark.createdAt = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    // BookmarkDB.insert(bookmark);
    BookmarkEditDialog.show(context, bookmark);
    reload();
  }
}
