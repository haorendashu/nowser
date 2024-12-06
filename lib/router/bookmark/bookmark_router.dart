import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_pinned_shortcut_plus/flutter_pinned_shortcut_plus.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:nostr_sdk/utils/string_util.dart';
import 'package:nowser/component/bookmark_edit_dialog.dart';
import 'package:nowser/component/cust_state.dart';
import 'package:nowser/component/deletable_list_mixin.dart';
import 'package:nowser/component/url_list_item_componnet.dart';
import 'package:nowser/main.dart';
import 'package:nowser/provider/bookmark_provider.dart';
import 'package:nowser/util/router_util.dart';
import 'package:provider/provider.dart';

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
  @override
  Future<void> onReady(BuildContext context) async {}

  List<int> selectedIds = [];

  @override
  Widget doBuild(BuildContext context) {
    var themeData = Theme.of(context);
    var _bookmarkProvider = Provider.of<BookmarkProvider>(context);
    var bookmarks = _bookmarkProvider.bookmarks;

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

          List<Widget> slidableActionList = [];
          if (Platform.isAndroid) {
            slidableActionList.add(SlidableAction(
              onPressed: (context) {
                doAddPinnedShortcut(bookmark);
              },
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              icon: Icons.add_home,
              label: 'Desktop',
            ));
          }
          slidableActionList.add(SlidableAction(
            onPressed: (context) {
              doEdit(bookmark);
            },
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'Edit',
          ));

          main = Slidable(
            endActionPane: ActionPane(
              motion: ScrollMotion(),
              children: slidableActionList,
            ),
            child: main,
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
      await bookmarkProvider.reload();
      selectedIds.clear();
    }
  }

  final _flutterPinnedShortcutPlugin = FlutterPinnedShortcut();

  Future<void> doAddPinnedShortcut(Bookmark bookmark) async {
    File? file;
    if (StringUtil.isNotBlank(bookmark.favicon)) {
      // use favicon as icon
      file = await DefaultCacheManager().getSingleFile(bookmark.favicon!);
    } else {
      // use default image as icon
      // file =
      print("favicon not found!");
      return;
    }

    if (StringUtil.isBlank(bookmark.title) ||
        StringUtil.isBlank(bookmark.url)) {
      return;
    }

    _flutterPinnedShortcutPlugin.createPinnedShortcut(
        id: StringUtil.rndNameStr(10),
        label: bookmark.title!,
        action: bookmark.url!,
        iconAssetName: "assets/logo_android.png",
        iconUri: Uri.file(file.path).toString());
  }

  Future<void> doEdit(Bookmark bookmark) async {
    await BookmarkEditDialog.show(context, bookmark);
    bookmarkProvider.reload();
  }
}
