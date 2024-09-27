import 'package:flutter/material.dart';
import 'package:nowser/component/cust_state.dart';
import 'package:nowser/component/deletable_list_mixin.dart';
import 'package:nowser/component/url_list_item_componnet.dart';
import 'package:nowser/util/router_util.dart';

import '../../component/appbar_back_btn_component.dart';
import '../../data/bookmark.dart';
import '../../data/bookmark_db.dart';

class BookmarkRouter extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _BookmarkRouter();
  }
}

class _BookmarkRouter extends CustState<BookmarkRouter>
    with DeletableListMixin {
  List<Bookmark> bookmarks = [];

  @override
  Future<void> onReady(BuildContext context) async {
    bookmarks = await BookmarkDB.all();
    setState(() {});
  }

  List<int> selectedIds = [];

  @override
  Widget doBuild(BuildContext context) {
    var themeData = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: AppbarBackBtnComponent(),
        title: Text(
          "Bookmarks",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: themeData.textTheme.bodyLarge!.fontSize,
          ),
        ),
        actions: genAppBarActions(context),
      ),
      body: ListView.builder(
        itemBuilder: (context, index) {
          if (index >= bookmarks.length) {
            return null;
          }

          var bookmark = bookmarks[index];

          Widget main = UrlListItemComponnet(
            selectable: deleting,
            selected: selectedIds.contains(bookmark.id),
            image: bookmark.favicon,
            title: bookmark.title ?? "",
            url: bookmark.url ?? "",
          );

          main = wrapListItem(main, onTap: () {
            RouterUtil.back(context, bookmark.url);
          }, onSelect: () {
            if (!selectedIds.contains(bookmark.id)) {
              setState(() {
                selectedIds.add(bookmark.id!);
              });
            }
          });

          return main;
        },
        itemCount: bookmarks.length,
      ),
    );
  }

  @override
  Future<void> doDelete() async {
    if (selectedIds.isNotEmpty) {
      await BookmarkDB.deleteByIds(selectedIds);
      bookmarks.removeWhere((o) {
        return selectedIds.contains(o.id);
      });
      selectedIds.clear();
    }
  }
}
