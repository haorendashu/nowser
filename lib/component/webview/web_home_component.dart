import 'package:flutter/material.dart';
import 'package:nowser/component/auth_dialog/auth_app_connect_dialog.dart';
import 'package:nowser/component/auth_dialog/auth_dialog.dart';
import 'package:nowser/component/auth_dialog/auth_dialog_base_componnet.dart';
import 'package:nowser/component/bookmark_edit_dialog.dart';
import 'package:nowser/component/webview/web_home_btn_component.dart';
import 'package:nowser/component/webview/web_info.dart';
import 'package:nowser/const/base.dart';
import 'package:nowser/data/bookmark.dart';
import 'package:nowser/main.dart';
import 'package:nowser/provider/bookmark_provider.dart';
import 'package:nowser/router/web_url_input/web_url_input_router.dart';
import 'package:provider/provider.dart';

import '../../const/router_path.dart';
import '../../util/router_util.dart';
import 'webview_number_component.dart';

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
    var _bookmarkProvider = Provider.of<BookmarkProvider>(context);
    List<Widget> mainList = [];

    mainList.add(Container(
      margin: const EdgeInsets.only(
        bottom: 40,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Image(
            width: 50,
            height: 50,
            image: AssetImage("assets/imgs/logo/logo512.png"),
          ),
          Container(
            margin: const EdgeInsets.only(
              left: Base.BASE_PADDING,
              right: Base.BASE_PADDING,
            ),
            child: const Text(
              "Nowser",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    ));

    mainList.add(Hero(
      tag: "urlInput",
      child: Material(
        child: TextField(
          controller: textEditingController,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          readOnly: true,
          onTap: () async {
            var value =
                await RouterUtil.router(context, RouterPath.WEB_URL_INPUT);
            if (value != null && value is String && value.startsWith("http")) {
              widget.webInfo.url = value;
              widget.webInfo.title = null;

              webProvider.updateWebInfo(widget.webInfo);
            }
          },
        ),
      ),
    ));

    var indexBookmarks = _bookmarkProvider.indexBookmarks;
    var indexBookmarksLenght = indexBookmarks.length;
    List<Widget> indexBtns1 = [];
    for (var i = 0; i < 5; i++) {
      indexBtns1.add(buildIndexBtn(indexBookmarks, i));
    }
    List<Widget> indexBtns2 = [];
    for (var i = 0; i < 5; i++) {
      indexBtns2.add(buildIndexBtn(indexBookmarks, i + 5));
    }
    // if (indexBookmarksLenght > 0) {
    mainList.add(Container(
      // color: Colors.red,
      margin: const EdgeInsets.only(
        top: 30,
      ),
      padding: const EdgeInsets.only(
        left: Base.BASE_PADDING,
        right: Base.BASE_PADDING,
      ),
      child: Row(
        children: indexBtns1,
      ),
    ));
    // }
    // if (indexBookmarksLenght > 5) {
    mainList.add(Container(
      // color: Colors.pink,
      margin: const EdgeInsets.only(
        top: Base.BASE_PADDING,
      ),
      padding: const EdgeInsets.only(
        left: Base.BASE_PADDING,
        right: Base.BASE_PADDING,
      ),
      child: Row(
        children: indexBtns2,
      ),
    ));
    // }

    return Container(
      padding: EdgeInsets.all(Base.BASE_PADDING),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: mainList,
              ),
            ),
          ),
          Container(
            height: 60,
            child: Row(
              children: [
                wrapBottomBtn(
                    Container(
                      alignment: Alignment.center,
                      child: WebViewNumberComponent(),
                    ), onTap: () {
                  RouterUtil.router(context, RouterPath.WEB_TABS);
                }),
                // wrapBottomBtn(const Icon(Icons.space_dashboard), onTap: () {
                //   // AuthDialog.show(context);
                //   // AuthAppConnectDialog.show(context);
                // }),
                wrapBottomBtn(const Icon(Icons.segment), onTap: () {
                  // AuthDialog.show(context);
                  RouterUtil.router(context, RouterPath.ME);
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget wrapBottomBtn(Widget btn, {Function? onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (onTap != null) {
            onTap();
          }
        },
        child: Container(
          child: btn,
        ),
      ),
    );
  }

  Widget buildIndexBtn(List<Bookmark> bookmarks, int index) {
    Widget main = Container();
    Bookmark? bookmark;
    if (index < bookmarks.length) {
      bookmark = bookmarks[index];
    }

    if (bookmark != null) {
      main = WebHomeBtnComponent(bookmark!);
    } else {
      if (bookmarks.length == index) {
        main = GestureDetector(
          onTap: () {
            BookmarkEditDialog.show(
              context,
              Bookmark(
                addedToIndex: 1,
              ),
            );
          },
          child: Container(
            child: Icon(Icons.add),
          ),
        );
      }
    }

    return Expanded(
      child: Container(
        height: 68,
        child: main,
      ),
    );
  }
}
