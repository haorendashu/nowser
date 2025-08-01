import 'package:flutter/material.dart';
import 'package:nostr_sdk/nip19/nip19.dart';
import 'package:nostr_sdk/utils/string_util.dart';
import 'package:nowser/component/user/user_name_component.dart';
import 'package:nowser/const/base.dart';
import 'package:nowser/data/app.dart';
import 'package:nowser/provider/key_provider.dart';
import 'package:nowser/util/router_util.dart';
import 'package:provider/provider.dart';

import '../../generated/l10n.dart';
import '../app/simple_app_info_component.dart';
import '../logo_component.dart';

class AuthDialogBaseComponnet extends StatefulWidget {
  App app;

  String title;

  Widget child;

  Function? onReject;

  Function onConfirm;

  Function(String)? onPubkeyChange;

  bool pubkeyReadonly;

  AuthDialogBaseComponnet({
    required this.app,
    required this.title,
    required this.child,
    this.onReject,
    required this.onConfirm,
    this.onPubkeyChange,
    this.pubkeyReadonly = false,
  });

  @override
  State<StatefulWidget> createState() {
    return _AuthDialog();
  }
}

class _AuthDialog extends State<AuthDialogBaseComponnet> {
  late S s;

  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);
    var baseMargin = const EdgeInsets.only(
      top: Base.BASE_PADDING_HALF,
      bottom: Base.BASE_PADDING_HALF,
    );
    var hintColor = themeData.hintColor;
    s = S.of(context);

    List<Widget> list = [];

    var keyWidget =
        Selector<KeyProvider, List<String>>(builder: (context, pubkeys, child) {
      List<DropdownMenuItem<String>> items = [];
      for (var pubkey in pubkeys) {
        items.add(DropdownMenuItem(
          value: pubkey,
          child: UserNameComponent(
            pubkey,
            showBoth: true,
            fullNpubName: true,
          ),
        ));
      }

      if (StringUtil.isBlank(widget.app.pubkey) && pubkeys.isNotEmpty) {
        widget.app.pubkey = pubkeys.first;
      }

      return DropdownButton<String>(
        items: items,
        isExpanded: true,
        onChanged: widget.pubkeyReadonly
            ? null
            : (String? value) {
                if (StringUtil.isNotBlank(value)) {
                  widget.app.pubkey = value;
                  setState(() {});
                }
              },
        value: widget.app.pubkey,
      );
    }, selector: (context, provider) {
      return provider.pubkeys;
    });

    var topWidget = Container(
      child: Row(
        children: [
          Container(
            margin: const EdgeInsets.only(
              left: Base.BASE_PADDING,
              right: Base.BASE_PADDING,
              top: Base.BASE_PADDING_HALF,
              bottom: Base.BASE_PADDING_HALF,
            ),
            child: LogoComponent(),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(right: Base.BASE_PADDING_HALF),
              alignment: Alignment.centerRight,
              child: keyWidget,
            ),
          ),
        ],
      ),
    );

    list.add(Container(
      alignment: Alignment.center,
      margin: baseMargin,
      child: Text(
        widget.title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: themeData.textTheme.bodyLarge!.fontSize,
        ),
      ),
    ));

    list.add(Container(
      margin: baseMargin,
      child: SimpleAppInfoComponent(
        app: widget.app,
      ),
    ));

    list.add(Container(
      margin: baseMargin,
      child: widget.child,
    ));

    list.add(Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // FilledButton(onPressed: () {}, child: Text("Cancel")),
          // OutlinedButton(
          //   onPressed: () {},
          //   child: Text(
          //     "Cancel",
          //     style: TextStyle(
          //       color: Colors.red,
          //     ),
          //   ),
          //   style: ,
          // ),
          FilledButton(
            onPressed: () {
              if (widget.onReject != null) {
                widget.onReject!();
              } else {
                RouterUtil.back(context);
              }
            },
            child: Text(s.Cancel),
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(Colors.red),
            ),
          ),
          Container(
            margin: EdgeInsets.only(
              left: Base.BASE_PADDING_HALF,
            ),
            child: FilledButton(
              onPressed: () {
                widget.onConfirm();
              },
              child: Text(s.Confirm),
            ),
          )
        ],
      ),
    ));

    return Dialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(Base.BASE_PADDING),
            decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(color: hintColor.withOpacity(0.3)))),
            child: topWidget,
          ),
          Container(
            padding: EdgeInsets.all(Base.BASE_PADDING),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: list,
            ),
          ),
        ],
      ),
    );
  }
}
