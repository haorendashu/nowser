import 'package:flutter/material.dart';
import 'package:nostr_sdk/utils/string_util.dart';
import 'package:nowser/component/qrscanner.dart';
import 'package:nowser/data/bookmark.dart';
import 'package:nowser/main.dart';
import 'package:nowser/provider/bookmark_provider.dart';
import 'package:nowser/util/router_util.dart';
import 'package:provider/provider.dart';
import 'package:searchfield/searchfield.dart';

import '../../const/base.dart';

class WebUrlInputRouter extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _WebUrlInputRouter();
  }
}

class _WebUrlInputRouter extends State<WebUrlInputRouter> {
  TextEditingController textEditingController = TextEditingController();

  String? url;

  late FocusNode focusNode;

  @override
  void initState() {
    super.initState();
    focusNode = FocusNode();
    Future.delayed(const Duration(milliseconds: 350), () {
      focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (url == null) {
      var arg = RouterUtil.routerArgs(context);
      if (arg != null && arg is String) {
        url = arg;
        textEditingController.text = arg;
      }
    }

    var bookmarkProvider = Provider.of<BookmarkProvider>(context);
    var bookmarks = bookmarkProvider.bookmarks;

    List<Widget> list = [];

    List<SearchFieldListItem<Bookmark>> suggestions = [];
    for (var bookmark in bookmarks) {
      suggestions.add(SearchFieldListItem(
        bookmark.url!,
        item: bookmark,
      ));
    }
    var inputWidget = Hero(
      tag: "urlInput",
      child: Material(
        child: SearchField(
          suggestions: suggestions,
          controller: textEditingController,
          suggestionDirection: SuggestionDirection.up,
          searchInputDecoration: SearchInputDecoration(
            border: OutlineInputBorder(),
          ),
          onSubmit: (value) {
            checkAndBack(value);
          },
          focusNode: focusNode,
          onSuggestionTap: (suggestion) {
            var item = suggestion.item;
            if (item != null) {
              checkAndBack(item.url);
            }
          },
          onSearchTextChanged: (input) {
            print("onSearchTextChanged");
            List<SearchFieldListItem> matchList = [];
            if (StringUtil.isBlank(input)) {
              return matchList;
            }

            for (var suggestion in suggestions) {
              var item = suggestion.item;
              if (item != null && StringUtil.isNotBlank(item.url)) {
                if (item.url!.contains(input)) {
                  matchList.add(suggestion);
                  continue;
                }

                if (item.title != null && item.title!.contains(input)) {
                  matchList.add(suggestion);
                  continue;
                }
              }
            }

            return matchList;
          },
        ),
      ),
    );

    list.add(Expanded(child: Container()));
    list.add(Container(
      padding: const EdgeInsets.all(Base.BASE_PADDING),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              RouterUtil.back(context);
            },
            behavior: HitTestBehavior.translucent,
            child: Container(
              padding: EdgeInsets.only(right: Base.BASE_PADDING),
              child: Icon(Icons.chevron_left),
            ),
          ),
          Expanded(child: inputWidget),
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            child: Container(
              padding: const EdgeInsets.only(left: Base.BASE_PADDING),
              child: GestureDetector(
                onTap: () async {
                  var url = await QRScanner.show(context);
                  checkAndBack(url);
                },
                child: Icon(Icons.qr_code_scanner),
              ),
            ),
          ),
        ],
      ),
    ));

    return Scaffold(
      body: Container(
        child: Column(
          children: list,
        ),
      ),
    );
  }

  void checkAndBack(String? value) {
    if (StringUtil.isNotBlank(value) && value!.startsWith("http")) {
      RouterUtil.back(context, value);
      return;
    }
    // TODO check if this is a url without http or https, add and open it !

    // search
    if (StringUtil.isNotBlank(value)) {
      String? searchUrl = settingProvider.searchEngine;
      searchUrl ??= "https://duckduckgo.com/?&q=";
      searchUrl += value!;
      print(searchUrl);
      RouterUtil.back(context, searchUrl);
    }
  }
}
