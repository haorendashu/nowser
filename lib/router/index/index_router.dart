import 'dart:math';

import 'package:flutter/material.dart';
import 'package:nostr_sdk/utils/platform_util.dart';
import 'package:nostr_sdk/utils/string_util.dart';
import 'package:nowser/component/cust_state.dart';
import 'package:nowser/component/image_component.dart';
import 'package:nowser/component/webview/web_home_component.dart';
import 'package:nowser/main.dart';
import 'package:nowser/provider/web_provider.dart';
import 'package:nowser/router/index/index_web_component.dart';
import 'package:nowser/util/router_util.dart';
import 'package:provider/provider.dart';

import '../../component/webview/webview_component.dart';
import '../../provider/android_signer_mixin.dart';
import '../../provider/permission_check_mixin.dart';
import 'web_control_component.dart';

class IndexRouter extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _IndexRouter();
  }
}

class _IndexRouter extends CustState<IndexRouter>
    with PermissionCheckMixin, AndroidSignerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Future<void> onReady(BuildContext context) async {
    await remoteSigningProvider.reload();
    await remoteSigningProvider.reloadPenddingRemoteApps();
  }

  @override
  Widget doBuild(BuildContext context) {
    if (PlatformUtil.isAndroid()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        handleInitialIntent(context);
      });
    }
    remoteSigningProvider.updateContext(context);
    webProvider.checkBlank();

    var _webProvider = Provider.of<WebProvider>(context);

    var main = IndexedStack(
      index: _webProvider.index,
      children: _webProvider.getIndexWebviews(context, showControl),
    );

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        var closeBottomSheet = closeControl();
        if (closeBottomSheet) {
          return;
        }

        var webInfo = webProvider.currentWebInfo();
        if (webInfo != null) {
          webProvider.goBack(webInfo);
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        body: main,
      ),
    );
  }

  PersistentBottomSheetController? bottomSheetController;

  showControl() {
    bottomSheetController = _scaffoldKey.currentState!.showBottomSheet(
      (context) {
        return WebControlComponent(closeControl);
      },
      enableDrag: true,
      showDragHandle: true,
    );
    bottomSheetController!.closed.then((v) {
      bottomSheetController = null;
    });
  }

  bool closeControl() {
    bool closeAble = false;
    try {
      if (bottomSheetController != null) {
        closeAble = true;
        bottomSheetController!.close();
      }
    } catch (e) {}
    bottomSheetController = null;
    return closeAble;
  }
}
