import 'package:flutter/material.dart';
import 'package:nostr_sdk/utils/platform_util.dart';
import 'package:nowser/provider/download_provider.dart';
import 'package:nowser/util/router_util.dart';

import '../const/base.dart';
import '../generated/l10n.dart';
import '../main.dart';
import '../util/table_mode_util.dart';

class DownloadTaskDialog extends StatefulWidget {
  String downloadUrl;

  DownloadTaskDialog(this.downloadUrl);

  static Future<void> show(BuildContext context, String downloadUrl) async {
    await showDialog<String>(
      context: context,
      builder: (_context) {
        return DownloadTaskDialog(downloadUrl);
      },
    );
  }

  @override
  State<StatefulWidget> createState() {
    return _DownloadTaskDialog();
  }
}

class _DownloadTaskDialog extends State<DownloadTaskDialog> {
  TextEditingController urlTextController = TextEditingController();

  TextEditingController fileNameTextController = TextEditingController();

  late S s;

  @override
  void initState() {
    super.initState();
    String fileName =
        widget.downloadUrl.substring(widget.downloadUrl.lastIndexOf('/') + 1);

    urlTextController.text = widget.downloadUrl;
    fileNameTextController.text = fileName;
  }

  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);
    s = S.of(context);

    List<Widget> list = [];
    list.add(Container(
      margin: EdgeInsets.only(
        bottom: Base.BASE_PADDING,
      ),
      child: Text(
        s.Downloads,
        style: TextStyle(
          fontSize: themeData.textTheme.bodyLarge!.fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
    ));

    list.add(Container(
      child: TextField(
        controller: urlTextController,
        decoration: InputDecoration(
          labelText: s.Url,
        ),
      ),
    ));

    list.add(Container(
      child: TextField(
        controller: fileNameTextController,
        decoration: InputDecoration(
          labelText: s.Name,
        ),
      ),
    ));

    list.add(Container(
      margin: EdgeInsets.only(
        top: Base.BASE_PADDING * 2,
        bottom: Base.BASE_PADDING,
      ),
      width: double.infinity,
      child: FilledButton(onPressed: confirm, child: Text(s.Confirm)),
    ));

    Widget main = Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: list,
      ),
    );
    if (PlatformUtil.isPC() || TableModeUtil.isTableMode()) {
      main = Container(
        width: mediaDataCache.size.width / 2,
        child: main,
      );
    }

    return Dialog(
      child: Container(
        padding: EdgeInsets.all(Base.BASE_PADDING * 2),
        child: main,
      ),
    );
  }

  void confirm() {
    var url = urlTextController.text;
    var fileName = fileNameTextController.text;
    downloadProvider.startDownload(url, fileName);
    RouterUtil.back(context);
  }
}
