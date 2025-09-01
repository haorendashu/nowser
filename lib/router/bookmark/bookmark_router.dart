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
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

import '../../component/appbar_back_btn_component.dart';
import '../../data/bookmark.dart';
import '../../data/bookmark_db.dart';
import '../../generated/l10n.dart';

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
    var s = S.of(context);
    var themeData = Theme.of(context);
    var _bookmarkProvider = Provider.of<BookmarkProvider>(context);
    var bookmarks = _bookmarkProvider.bookmarks;

    return Scaffold(
      appBar: AppBar(
        leading: AppbarBackBtnComponent(),
        title: Text(
          s.Bookmarks,
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
              label: s.Desktop,
            ));
          }
          slidableActionList.add(SlidableAction(
            onPressed: (context) {
              doEdit(bookmark);
            },
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: s.Edit,
          ));

          main = Slidable(
            endActionPane: ActionPane(
              motion: ScrollMotion(),
              children: slidableActionList,
            ),
            child: main,
          );

          main =
              wrapListItem(main, selectedIds.contains(bookmark.id), onTap: () {
            RouterUtil.back(context, bookmark.url);
          }, onSelect: () {
            if (!selectedIds.contains(bookmark.id)) {
              setState(() {
                selectedIds.add(bookmark.id!);
              });
            } else {
              setState(() {
                selectedIds.remove(bookmark.id!);
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

    final originalBytes = await file.readAsBytes();
    final originalImage = img.decodeImage(originalBytes);
    if (originalImage == null) {
      print("Failed to decode image");
      return;
    }

    final targetSize = 256;
    final newImage = img.Image(width: targetSize, height: targetSize);
    img.fill(newImage, color: img.ColorRgb8(240, 240, 240));

    final scale = (targetSize * 0.6).toDouble() /
        (originalImage.width > originalImage.height
            ? originalImage.width
            : originalImage.height);
    final int newWidth = (originalImage.width * scale).round();
    final int newHeight = (originalImage.height * scale).round();

    final resizedImage =
        img.copyResize(originalImage, width: newWidth, height: newHeight);

    final int x = (targetSize - newWidth) ~/ 2;
    final int y = (targetSize - newHeight) ~/ 2;

    img.compositeImage(newImage, resizedImage, dstX: x, dstY: y);

    final tempDir = await getTemporaryDirectory();
    final resizedFile = File(
        '${tempDir.path}/icon_${DateTime.now().millisecondsSinceEpoch}.png');
    await resizedFile.writeAsBytes(img.encodePng(newImage));

    if (StringUtil.isBlank(bookmark.title) ||
        StringUtil.isBlank(bookmark.url)) {
      return;
    }

    _flutterPinnedShortcutPlugin.createPinnedShortcut(
        id: StringUtil.rndNameStr(10),
        label: bookmark.title!,
        action: bookmark.url!,
        iconAssetName: "assets/logo_android.png",
        iconUri: Uri.file(resizedFile.path).toString());
  }

  Future<void> doEdit(Bookmark bookmark) async {
    await BookmarkEditDialog.show(context, bookmark);
  }
}
