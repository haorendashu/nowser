import 'package:flutter/material.dart';
import 'package:nowser/component/cust_state.dart';
import 'package:nowser/component/url_list_item_componnet.dart';
import 'package:nowser/data/browser_history_db.dart';
import 'package:nowser/util/router_util.dart';

import '../../component/appbar_back_btn_component.dart';
import '../../const/base.dart';
import '../../data/browser_history.dart';

class HistoryRouter extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HistoryRouter();
  }
}

class _HistoryRouter extends CustState<HistoryRouter> {
  List<BrowserHistory> historys = [];

  @override
  Future<void> onReady(BuildContext context) async {
    historys = await BrowserHistoryDB.all();
    setState(() {});
  }

  @override
  Widget doBuild(BuildContext context) {
    var themeData = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: AppbarBackBtnComponent(),
        title: Text(
          "Historys",
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
          if (index >= historys.length) {
            return null;
          }

          Widget? dateWidget;
          var history = historys[index];
          if (index > 0) {
            var preHistory = historys[index - 1];

            var preDate = DateTime.fromMillisecondsSinceEpoch(
                preHistory.createdAt! * 1000);
            var currentDate =
                DateTime.fromMillisecondsSinceEpoch(history.createdAt! * 1000);
            if (preDate.day != currentDate.day) {
              dateWidget = Container(
                padding: EdgeInsets.only(
                    top: Base.BASE_PADDING, left: Base.BASE_PADDING * 2),
                alignment: Alignment.centerLeft,
                child: Text("${currentDate.month}-${currentDate.day}"),
              );
            }
          }

          var main = Container(
            child: GestureDetector(
              onTap: () {
                RouterUtil.back(context, history.url);
              },
              child: UrlListItemComponnet(
                image: history.favicon,
                title: history.title ?? "",
                url: history.url ?? "",
                dateTime: history.createdAt,
              ),
            ),
          );

          if (dateWidget != null) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [dateWidget, main],
            );
          }

          return main;
        },
        itemCount: historys.length,
      ),
    );
  }
}
