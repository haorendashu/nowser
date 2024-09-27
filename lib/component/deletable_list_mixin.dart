import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';

import '../const/base.dart';

mixin DeletableListMixin<T extends StatefulWidget> on State<T> {
  bool deleting = false;

  List<Widget> genAppBarActions(BuildContext context) {
    return deleting
        ? [
            GestureDetector(
              onTap: delete,
              child: Container(
                padding: const EdgeInsets.all(Base.BASE_PADDING),
                child: Icon(Icons.delete_sweep_outlined),
              ),
            ),
          ]
        : [];
  }

  Widget wrapListItem(Widget child,
      {required Function onTap, required Function onSelect}) {
    if (deleting) {
      return GestureDetector(
        onTap: () {
          onSelect();
        },
        child: child,
      );
    } else {
      return GestureDetector(
        onTap: () {
          onTap();
        },
        onLongPress: () {
          setState(() {
            deleting = true;
          });

          onSelect();
        },
        child: child,
      );
    }
  }

  Future<void> delete() async {
    var cancelFunc = BotToast.showLoading();
    try {
      await doDelete();
    } catch (e) {
      print("delete  error " + e.toString());
    } finally {
      cancelFunc.call();
    }

    setState(() {
      deleting = false;
    });
  }

  Future<void> doDelete() async {}
}
