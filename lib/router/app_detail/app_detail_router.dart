import 'package:flutter/material.dart';
import 'package:nostr_sdk/nip19/nip19.dart';
import 'package:nostr_sdk/utils/string_util.dart';
import 'package:nowser/component/app/app_type_component.dart';
import 'package:nowser/component/image_component.dart';
import 'package:nowser/const/connect_type.dart';
import 'package:nowser/data/app.dart';
import 'package:nowser/main.dart';
import 'package:nowser/router/app_detail/app_detail_permission_item_component.dart';
import 'package:nowser/util/router_util.dart';
import 'package:provider/provider.dart';

import '../../component/appbar_back_btn_component.dart';
import '../../const/base.dart';
import '../../provider/key_provider.dart';

class AppDetailRouter extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AppDetailRouter();
  }
}

class _AppDetailRouter extends State<AppDetailRouter> {
  late TextEditingController nameController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    nameController.addListener(() {
      if (app != null && !changed && nameController.text != app!.name) {
        setState(() {
          changed = true;
        });
      }
    });
  }

  App? app;

  bool changed = false;

  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);
    var arg = RouterUtil.routerArgs(context);
    if (arg != null && arg is App) {
      if (app == null || app!.id != arg.id) {
        app = App.fromJson(arg.toJson());
        print(app!.name);
        nameController.text = app!.name ?? "";
      }
    }

    if (app == null) {
      RouterUtil.back(context);
      return Container();
    }

    List<Widget> list = [];

    var baseMargin = EdgeInsets.only(bottom: Base.BASE_PADDING);

    Widget imageWidget = Icon(
      Icons.image,
      size: 80,
    );
    if (StringUtil.isNotBlank(app!.image)) {
      imageWidget = ImageComponent(
        imageUrl: app!.image!,
        width: 80,
        height: 80,
      );
    }

    list.add(Container(
      margin: baseMargin,
      child: Row(
        children: [
          Container(
            margin: EdgeInsets.only(right: Base.BASE_PADDING * 2),
            child: Container(
              width: 80,
              height: 80,
              child: imageWidget,
            ),
          ),
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppTypeComponent(app!.appType!),
                Text(
                  app!.code!,
                  style: TextStyle(color: themeData.hintColor),
                ),
              ],
            ),
          ),
        ],
      ),
    ));

    list.add(Container(
      margin: baseMargin,
      child: TextField(
        controller: nameController,
        decoration: InputDecoration(hintText: "Name"),
      ),
    ));

    var keyWidget =
        Selector<KeyProvider, List<String>>(builder: (context, pubkeys, child) {
      List<DropdownMenuItem<String>> items = [];
      for (var pubkey in pubkeys) {
        items.add(DropdownMenuItem(
          value: pubkey,
          child: Text(
            Nip19.encodePubKey(pubkey),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ));
      }
      return DropdownButton<String>(
        items: items,
        isExpanded: true,
        onChanged: null,
        value: app!.pubkey,
      );
    }, selector: (context, provider) {
      return provider.pubkeys;
    });
    list.add(Container(
      child: Row(
        children: [
          Container(
            margin: EdgeInsets.only(right: Base.BASE_PADDING),
            child: Text("Pubkey:"),
          ),
          Expanded(child: keyWidget),
        ],
      ),
    ));

    List<DropdownMenuItem<int>> connectTypeItems = [];
    connectTypeItems.add(DropdownMenuItem(
        child: Text("Fully trust"), value: ConnectType.FULLY_TRUST));
    connectTypeItems.add(DropdownMenuItem(
        child: Text("Reasonable"), value: ConnectType.REASONABLE));
    connectTypeItems.add(DropdownMenuItem(
        child: Text("Alway reject"), value: ConnectType.ALWAY_REJECT));
    list.add(Container(
      margin: baseMargin,
      child: Row(
        children: [
          Container(
            margin: EdgeInsets.only(right: Base.BASE_PADDING),
            child: Text("ConnectType:"),
          ),
          Expanded(
              child: DropdownButton<int>(
            items: connectTypeItems,
            isExpanded: true,
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  changed = true;
                  app!.connectType = value;
                });
              }
            },
            value: app!.connectType,
          )),
        ],
      ),
    ));

    if (app!.connectType == ConnectType.REASONABLE) {
      if (StringUtil.isNotBlank(app!.alwaysAllow)) {
        var permissionItems =
            getPermissionItems(context, app!.alwaysAllow!, true);

        if (permissionItems.isNotEmpty) {
          list.add(Container(
            margin: baseMargin,
            alignment: Alignment.centerLeft,
            child: Text(
              "Always Allow:",
            ),
          ));
          list.add(Container(
            width: double.infinity,
            child: Wrap(
              spacing: Base.BASE_PADDING,
              runSpacing: Base.BASE_PADDING,
              children: permissionItems,
            ),
          ));
        }
      }

      if (StringUtil.isNotBlank(app!.alwaysReject)) {
        var permissionItems =
            getPermissionItems(context, app!.alwaysReject!, false);

        if (permissionItems.isNotEmpty) {
          list.add(Container(
            margin: baseMargin,
            alignment: Alignment.centerLeft,
            child: Text(
              "Always Reject:",
            ),
          ));
          list.add(Container(
            width: double.infinity,
            child: Wrap(
              spacing: Base.BASE_PADDING,
              runSpacing: Base.BASE_PADDING,
              children: permissionItems,
            ),
          ));
        }
      }
    }

    List<Widget> actions = [];
    if (changed == true) {
      actions.add(GestureDetector(
        onTap: appUpdate,
        child: Container(
          padding: const EdgeInsets.all(Base.BASE_PADDING),
          child: Icon(Icons.done),
        ),
      ));
    }

    return Scaffold(
      appBar: AppBar(
        leading: AppbarBackBtnComponent(),
        title: Text(
          "App Detail",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: themeData.textTheme.bodyLarge!.fontSize,
          ),
        ),
        actions: actions,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(Base.BASE_PADDING),
          child: Column(
            children: list,
          ),
        ),
      ),
    );
  }

  List<Widget> getPermissionItems(
      BuildContext context, String permissionText, bool allow) {
    var permissionTexts = permissionText.split(";");
    List<Widget> permissionItems = [];
    for (var permissionText in permissionTexts) {
      var strs = permissionText.split("-");
      var authType = int.tryParse(strs[0]);
      if (authType != null) {
        if (strs.length > 1) {
          var eventKindStrs = strs[1].split(",");
          for (var eventKindStr in eventKindStrs) {
            var eventKind = int.tryParse(eventKindStr);
            if (eventKind != null) {
              permissionItems.add(AppDetailPermissionItemComponent(
                allow,
                authType,
                eventKind: eventKind,
                onDelete: onPermissionDelete,
              ));
            }
          }
        } else {
          permissionItems.add(AppDetailPermissionItemComponent(
            allow,
            authType,
            onDelete: onPermissionDelete,
          ));
        }
      }
    }

    return permissionItems;
  }

  onPermissionDelete(bool allow, int authType, int? eventKind) {
    var sourceText = app!.alwaysAllow;
    if (!allow) {
      sourceText = app!.alwaysReject;
    }

    List<String> permissions = [];
    if (StringUtil.isNotBlank(sourceText)) {
      var permissionTexts = sourceText!.split(";");
      for (var permissionText in permissionTexts) {
        var strs = permissionText.split("-");
        var _authType = int.tryParse(strs[0]);
        if (_authType != authType) {
          permissions.add(permissionText);
        } else {
          // authType same, check eventKind
          if (eventKind == null || strs.length <= 1) {
            continue;
          } else {
            // should check eventKind
            List<String> checkedEventKindStrs = [];
            if (strs.length > 1) {
              var eventKindStrs = strs[1].split(",");
              for (var eventKindStr in eventKindStrs) {
                if (eventKindStr == "$eventKind") {
                  continue;
                } else {
                  checkedEventKindStrs.add(eventKindStr);
                }
              }
            }

            if (checkedEventKindStrs.isNotEmpty) {
              permissions.add("$_authType-${checkedEventKindStrs.join(",")}");
            }
          }
        }
      }
    }

    if (allow) {
      app!.alwaysAllow = permissions.join(";");
    } else {
      app!.alwaysReject = permissions.join(";");
    }
    changed = true;
    setState(() {});
  }

  void appUpdate() {
    app!.name = nameController.text;
    appProvider.update(app!);
    RouterUtil.back(context);
  }
}
