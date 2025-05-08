import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nowser/component/cust_state.dart';
import 'package:nowser/component/download_list_item_component.dart';
import 'package:nowser/data/download_log.dart';
import 'package:nowser/data/download_log_db.dart';
import 'package:nowser/provider/download_provider.dart';
import 'package:provider/provider.dart';

import '../../component/appbar_back_btn_component.dart';
import '../../component/deletable_list_mixin.dart';
import '../../const/base.dart';
import '../../generated/l10n.dart';
import '../../util/router_util.dart';

class DownloadsRouter extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _DownloadsRouter();
  }
}

class _DownloadsRouter extends CustState<DownloadsRouter>
    with DeletableListMixin {
  List<int> selectedIds = [];

  List<DownloadLog> completedLogs = [];

  @override
  Future<void> onReady(BuildContext context) async {
    var allList = await DownloadLogDB.all();
    print(allList);
    setState(() {
      completedLogs = allList;
    });
  }

  @override
  Widget doBuild(BuildContext context) {
    var themeData = Theme.of(context);
    var s = S.of(context);

    var _downloadProvider = Provider.of<DownloadProvider>(context);
    List<DownloadLog> currentDownloadLogs =
        _downloadProvider.currentDownloadLogs;

    List<Widget> list = [];
    for (var logItem in currentDownloadLogs) {
      list.add(wrapItem(DownloadListItemComponent(logItem), logItem));
    }

    int? lastMonth;
    int? lastDay;

    for (var logItem in completedLogs) {
      if (logItem.createdAt != null) {
        var date =
            DateTime.fromMillisecondsSinceEpoch(logItem.createdAt! * 1000);
        if (date.month != lastMonth || date.day != lastDay) {
          var dateStr = DateFormat.yMd().format(date);
          list.add(Container(
            margin: EdgeInsets.only(
                left: Base.BASE_PADDING, top: Base.BASE_PADDING),
            child: Text(
              dateStr,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ));
        }
      }

      list.add(wrapItem(DownloadListItemComponent(logItem), logItem));
    }

    return Scaffold(
      appBar: AppBar(
        leading: AppbarBackBtnComponent(),
        title: Text(
          s.Downloads,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: themeData.textTheme.bodyLarge!.fontSize,
          ),
        ),
        actions: genAppBarActions(context),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: list,
        ),
      ),
    );
  }

  Widget wrapItem(Widget child, DownloadLog downloadLog) {
    return wrapListItem(child, onTap: () {
      // RouterUtil.back(context, history.url);
    }, onSelect: () {
      if (!selectedIds.contains(downloadLog.id)) {
        setState(() {
          selectedIds.add(downloadLog.id!);
        });
      } else {
        setState(() {
          selectedIds.remove(downloadLog.id!);
        });
      }
    });
  }
}
