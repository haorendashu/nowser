import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:nostr_sdk/relay/relay_info.dart';
import 'package:nowser/const/base.dart';
import 'package:relay_sdk/network/connection.dart';
import 'package:relay_sdk/network/memory/mem_relay_client.dart';
import 'package:relay_sdk/relay_manager.dart';

import '../main.dart';
import '../util/ip_util.dart';

class BuildInRelayProvider extends ChangeNotifier {
  String ip = "127.0.0.1";

  static int port = 4870;

  RelayInfo relayInfo = RelayInfo(
      "${Base.APP_NAME}'s build-in relay",
      "This is a build-in relay for Nowser. It don't save any message and it's designed for NWC.",
      "29320975df855fe34a7b45ada2421e2c741c37c0136901fe477133a91eb18b07",
      "29320975df855fe34a7b45ada2421e2c741c37c0136901fe477133a91eb18b07",
      ["47"],
      Base.APP_NAME,
      Base.VERSION_NAME);

  RelayManager? _relayManager;

  bool isRunning() {
    if (_relayManager != null) {
      return true;
    }

    return false;
  }

  Future<void> start() async {
    if (isRunning()) {
      return;
    }

    String? localIp = await IpUtil.getIp();
    if (localIp != null) {
      ip = localIp;
    }

    try {
      var rm = _getRelayManager();
      await rm.start(relayInfo, port);

      await Future.delayed(const Duration(seconds: 10));

      if (_penddingMemRelayClients.isNotEmpty) {
        for (var memRelayClient in _penddingMemRelayClients) {
          rm.addMemClient(memRelayClient);
          try {
            memRelayClient.onConnected();
          } catch (e) {}
        }
      }
      _penddingMemRelayClients.clear();
    } catch (e) {
      print(e);
      BotToast.showText(text: "Start server fail.");
      if (_relayManager != null) {
        try {
          _relayManager!.stop();
        } catch (e) {}
      }
      _relayManager = null;
    }

    notifyListeners();
  }

  void stop() {
    if (_relayManager != null) {
      _relayManager!.stop();
    }

    _relayManager = null;

    notifyListeners();
  }

  RelayManager _getRelayManager() {
    if (_relayManager == null) {
      _relayManager = RelayManager(rootIsolateToken, Base.APP_NAME);
      _relayManager!.openFilterCheck = true;
      _relayManager!.openDB = false;
      // _relayManager!.trafficCounter = trafficCounterProvider;
      // _relayManager!.networkLogsManager = networkLogProvider;
      _relayManager!.rootIsolateToken = rootIsolateToken;
      _relayManager!.connectionListener = connectionListener;
    }

    return _relayManager!;
  }

  int connectionNum() {
    if (_relayManager != null) {
      return _relayManager!.getConnections().length;
    }

    return 0;
  }

  List<Connection> getConnections() {
    if (_relayManager != null) {
      return _relayManager!.getConnections();
    }

    return [];
  }

  void connectionListener() {
    notifyListeners();
  }

  List<MemRelayClient> _penddingMemRelayClients = [];

  void addMemClient(MemRelayClient memRelayClient) {
    if (isRunning()) {
      _relayManager!.addMemClient(memRelayClient);
    } else {
      _penddingMemRelayClients.add(memRelayClient);
    }
  }
}
