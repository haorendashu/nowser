import 'package:background_downloader/background_downloader.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nowser/component/cust_state.dart';
import 'package:nowser/main.dart';
import 'package:provider/provider.dart';
import 'package:open_file/open_file.dart';

import '../../component/appbar_back_btn_component.dart';
import '../../component/deletable_list_mixin.dart';
import '../../component/download_list_item_component.dart';
import '../../const/base.dart';
import '../../generated/l10n.dart';
import '../../provider/download_provider.dart';

class DownloadsRouter extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _DownloadsRouter();
  }
}

class _DownloadsRouter extends CustState<DownloadsRouter>
    with DeletableListMixin {
  List<String> selectedIds = [];

  @override
  Future<void> doDelete() async {
    await downloadProvider.deleteTasks(selectedIds);
    selectedIds.clear();
  }

  @override
  Future<void> onReady(BuildContext context) async {}

  @override
  Widget doBuild(BuildContext context) {
    var themeData = Theme.of(context);
    var s = S.of(context);

    var _downloadProvider = Provider.of<DownloadProvider>(context);
    var taskRecords = _downloadProvider.allRecords;

    List<Widget> list = [];

    int? lastMonth;
    int? lastDay;

    for (var taskRecord in taskRecords) {
      if (taskRecord.task.creationTime.month != lastMonth ||
          taskRecord.task.creationTime.day != lastDay) {
        var dateStr = DateFormat.yMd().format(taskRecord.task.creationTime);
        list.add(Container(
          margin: const EdgeInsets.only(
              left: Base.BASE_PADDING, top: Base.BASE_PADDING),
          child: Text(
            dateStr,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ));

        lastMonth = taskRecord.task.creationTime.month;
        lastDay = taskRecord.task.creationTime.day;
      }

      list.add(wrapItem(
        DownloadListItemComponent(
          taskRecord: taskRecord,
        ),
        taskRecord,
      ));
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

  Widget wrapItem(Widget child, TaskRecord taskRecord) {
    var id = taskRecord.taskId;
    return wrapListItem(child, selectedIds.contains(id), onTap: () async {
      if (taskRecord.status != TaskStatus.complete) {
        return;
      }

      var filepath = await taskRecord.task.filePath();
      await OpenFile.open(filepath);
    }, onSelect: () {
      if (!selectedIds.contains(id)) {
        setState(() {
          selectedIds.add(id);
        });
      } else {
        setState(() {
          selectedIds.remove(id);
        });
      }
    });
  }
}
