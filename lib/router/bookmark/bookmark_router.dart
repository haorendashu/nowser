import 'package:flutter/material.dart';
import 'package:nowser/component/cust_state.dart';
import 'package:nowser/component/url_list_item_componnet.dart';
import 'package:nowser/data/browser_history_db.dart';
import 'package:nowser/util/router_util.dart';

import '../../component/appbar_back_btn_component.dart';
import '../../const/base.dart';
import '../../data/bookmark.dart';
import '../../data/bookmark_db.dart';

class BookmarkRouter extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _BookmarkRouter();
  }
}

class _BookmarkRouter extends CustState<BookmarkRouter> {
  List<Bookmark> bookmarks = [];

  @override
  Future<void> onReady(BuildContext context) async {
    bookmarks = await BookmarkDB.all();
    setState(() {});
  }

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
        actions: [
          // GestureDetector(
          //   onTap: () {},
          //   child: Container(
          //     padding: const EdgeInsets.all(Base.BASE_PADDING),
          //     child: Icon(Icons.delete_sweep_outlined),
          //   ),
          // ),
        ],
      ),
      body: ListView.builder(
        itemBuilder: (context, index) {
          if (index >= bookmarks.length) {
            return null;
          }

          var bookmark = bookmarks[index];

          var main = Container(
            child: GestureDetector(
              onTap: () {
                RouterUtil.back(context, bookmark.url);
              },
              child: UrlListItemComponnet(
                image: bookmark.favicon,
                title: bookmark.title ?? "",
                url: bookmark.url ?? "",
              ),
            ),
          );

          return main;
        },
        itemCount: bookmarks.length,
      ),
    );
  }
}
