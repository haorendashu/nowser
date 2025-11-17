import 'dart:developer';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:nesigner_adapter/nesigner.dart';
import 'package:nesigner_adapter/nesigner_util.dart';
import 'package:nostr_sdk/event.dart';
import 'package:nostr_sdk/event_kind.dart';
import 'package:nostr_sdk/nip02/nip02.dart';
import 'package:nostr_sdk/nip07/nip07_signer.dart';
import 'package:nostr_sdk/nip19/nip19.dart';
import 'package:nostr_sdk/nip46/nostr_remote_signer.dart';
import 'package:nostr_sdk/nip46/nostr_remote_signer_info.dart';
import 'package:nostr_sdk/nip55/android_nostr_signer.dart';
import 'package:nostr_sdk/nip65/nip65.dart';
import 'package:nostr_sdk/nostr.dart';
import 'package:nostr_sdk/relay/relay.dart';
import 'package:nostr_sdk/relay/relay_base.dart';
import 'package:nostr_sdk/relay/relay_isolate.dart';
import 'package:nostr_sdk/relay/relay_mode.dart';
import 'package:nostr_sdk/relay/relay_status.dart';
import 'package:nostr_sdk/relay/relay_type.dart';
import 'package:nostr_sdk/relay_local/relay_local.dart';
import 'package:nostr_sdk/signer/local_nostr_signer.dart';
import 'package:nostr_sdk/signer/nostr_signer.dart';
import 'package:nostr_sdk/signer/pubkey_only_nostr_signer.dart';
import 'package:nostr_sdk/utils/platform_util.dart';
import 'package:nostr_sdk/utils/string_util.dart';

import '../const/client_connected.dart';
import '../main.dart';
import 'data_util.dart';

class RelayProvider extends ChangeNotifier {
  static RelayProvider? _relayProvider;

  List<String> relayAddrs = [];

  Map<String, RelayStatus> relayStatusMap = {};

  RelayStatus? relayStatusLocal;

  Map<String, RelayStatus> _tempRelayStatusMap = {};

  static RelayProvider getInstance() {
    if (_relayProvider == null) {
      _relayProvider = RelayProvider();
      // _relayProvider!._load();
    }
    return _relayProvider!;
  }

  void loadRelayAddrs(String? content) {
    var relays = parseRelayAddrs(content);
    if (relays.isEmpty) {
      relays = [
        "wss://purplepag.es", // indexer relay
        "wss://indexer.coracle.social", // indexer relay
        "wss://user.kindpag.es", // indexer relay
        "wss://nos.lol",
        // "wss://nostr.wine",
        // "wss://atlas.nostr.land",
        "wss://relay.damus.io",
        // "wss://nostr-relay.app",
        // "wss://nostr.oxtr.dev",
        // "wss://relayable.org",
        "wss://relay.primal.net",
        // "wss://relay.nostr.bg",
        "wss://relay.nostr.band",
        // "wss://yabu.me",
        // "wss://nostr.mom"
      ];
    }

    relayAddrs = relays;
  }

  List<String> parseRelayAddrs(String? content) {
    List<String> relays = [];
    if (StringUtil.isBlank(content)) {
      return relays;
    }

    var relayStatuses = NIP02.parseContenToRelays(content!);
    for (var relayStatus in relayStatuses) {
      var addr = relayStatus.addr;
      relays.add(addr);

      var oldRelayStatus = relayStatusMap[addr];
      if (oldRelayStatus != null) {
        oldRelayStatus.readAccess = relayStatus.readAccess;
        oldRelayStatus.writeAccess = relayStatus.writeAccess;
      } else {
        relayStatusMap[addr] = relayStatus;
      }
    }

    return relays;
  }

  RelayStatus? getRelayStatus(String addr) {
    return relayStatusMap[addr];
  }

  String relayNumStr() {
    var normalLength = relayAddrs.length;

    int connectedNum = 0;
    var it = relayStatusMap.values;
    for (var status in it) {
      if (status.connected == ClientConneccted.CONNECTED) {
        connectedNum++;
      }
    }
    return "$connectedNum / $normalLength";
  }

  int total() {
    return relayAddrs.length;
  }

  Future<Nostr?> genNostrWithKey(String key) async {
    NostrSigner? nostrSigner;
    if (Nip19.isPubkey(key)) {
      nostrSigner = PubkeyOnlyNostrSigner(Nip19.decode(key));
    } else if (AndroidNostrSigner.isAndroidNostrSignerKey(key)) {
      var pubkey = AndroidNostrSigner.getPubkeyFromKey(key);
      var package = AndroidNostrSigner.getPackageFromKey(key);
      nostrSigner = AndroidNostrSigner(pubkey: pubkey, package: package);
    } else if (NIP07Signer.isWebNostrSignerKey(key)) {
      var pubkey = NIP07Signer.getPubkey(key);
      nostrSigner = NIP07Signer(pubkey: pubkey);
    } else if (NostrRemoteSignerInfo.isBunkerUrl(key)) {
      var info = NostrRemoteSignerInfo.parseBunkerUrl(key);
      if (info == null) {
        return null;
      }

      bool hasConnected = false;
      if (StringUtil.isNotBlank(info.userPubkey)) {
        hasConnected = true;
      }

      nostrSigner = NostrRemoteSigner(RelayMode.BASE_MODE, info);
      await (nostrSigner as NostrRemoteSigner)
          .connect(sendConnectRequest: !hasConnected);

      if (StringUtil.isBlank(info.userPubkey)) {
        await nostrSigner.pullPubkey();
      }

      if (await nostrSigner.getPublicKey() == null) {
        return null;
      }
    } else if (Nesigner.isNesignerKey(key)) {
      var pinCode = Nesigner.getPinCodeFromKey(key);
      var pubkey = Nesigner.getPubkeyFromKey(key);
      nostrSigner = Nesigner(pinCode, pubkey: pubkey);
      try {
        if (!(await (nostrSigner as Nesigner).start())) {
          return null;
        }
      } catch (e) {
        return null;
      }
    } else {
      try {
        nostrSigner = LocalNostrSigner(key);
      } catch (e) {}
    }

    if (nostrSigner == null) {
      return null;
    }

    return await genNostr(nostrSigner);
  }

  Future<Nostr?> genNostr(NostrSigner signer) async {
    var pubkey = await signer.getPublicKey();
    if (pubkey == null) {
      return null;
    }

    var _nostr = Nostr(signer, pubkey, [], genTempRelay, onNotice: null);
    log("nostr init over");

    loadRelayAddrs(null);

    for (var relayAddr in relayAddrs) {
      log("begin to init $relayAddr");
      var custRelay = genRelay(relayAddr);
      try {
        _nostr.addRelay(custRelay, init: true);
      } catch (e) {
        log("relay $relayAddr add to pool error ${e.toString()}");
      }
    }

    return _nostr;
  }

  void onRelayStatusChange() {
    notifyListeners();
  }

  void addRelay(String relayAddr) {
    if (!relayAddrs.contains(relayAddr)) {
      relayAddrs.add(relayAddr);
      _doAddRelay(relayAddr);
    }
  }

  void _doAddRelay(String relayAddr,
      {bool init = false, int relayType = RelayType.NORMAL}) {
    var custRelay = genRelay(relayAddr, relayType: relayType);
    log("begin to init $relayAddr");
    nostr!.addRelay(custRelay,
        autoSubscribe: true, init: init, relayType: relayType);
  }

  void removeRelay(String relayAddr) {
    if (relayAddrs.contains(relayAddr)) {
      relayAddrs.remove(relayAddr);
      relayStatusMap.remove(relayAddr);
      nostr!.removeRelay(relayAddr);
    }
  }

  List<String> getWritableRelays() {
    List<String> list = [];
    for (var addr in relayAddrs) {
      var relayStatus = relayStatusMap[addr];
      if (relayStatus != null && relayStatus.writeAccess) {
        list.add(addr);
      }
    }
    return list;
  }

  List<RelayStatus> _getRelayStatuses() {
    List<RelayStatus> relayStatuses = [];
    for (var addr in relayAddrs) {
      var relayStatus = relayStatusMap[addr];
      if (relayStatus != null) {
        relayStatuses.add(relayStatus);
      }
    }
    return relayStatuses;
  }

  Relay genRelay(String relayAddr, {int relayType = RelayType.NORMAL}) {
    var relayStatus = relayStatusMap[relayAddr];
    if (relayStatus == null) {
      relayStatus = RelayStatus(relayAddr, relayType: relayType);
      relayStatusMap[relayAddr] = relayStatus;
    }

    return _doGenRelay(relayStatus);
  }

  Relay _doGenRelay(RelayStatus relayStatus) {
    var relayAddr = relayStatus.addr;

    return RelayBase(
      relayAddr,
      relayStatus,
    )..relayStatusCallback = onRelayStatusChange;
  }

  void relayUpdateByContactListEvent(Event event) {
    List<String> oldRelays = []..addAll(relayAddrs);
    loadRelayAddrs(event.content);
    _updateRelays(oldRelays);
  }

  void _updateRelays(List<String> oldRelays) {
    List<String> needToRemove = [];
    List<String> needToAdd = [];
    for (var oldRelay in oldRelays) {
      if (!relayAddrs.contains(oldRelay)) {
        // new addrs don't contain old relay, need to remove
        needToRemove.add(oldRelay);
      }
    }
    for (var relayAddr in relayAddrs) {
      if (!oldRelays.contains(relayAddr)) {
        // old addrs don't contain new relay, need to add
        needToAdd.add(relayAddr);
      }
    }

    for (var relayAddr in needToRemove) {
      relayStatusMap.remove(relayAddr);
      nostr!.removeRelay(relayAddr);
    }
    for (var relayAddr in needToAdd) {
      _doAddRelay(relayAddr);
    }
  }

  void clear() {
    // sharedPreferences.remove(DataKey.RELAY_LIST);
    relayStatusMap.clear();
    loadRelayAddrs(null);
    _tempRelayStatusMap.clear();
  }

  List<RelayStatus> tempRelayStatus() {
    List<RelayStatus> list = []..addAll(_tempRelayStatusMap.values);
    return list;
  }

  Relay genTempRelay(String addr) {
    var rs = _tempRelayStatusMap[addr];
    if (rs == null) {
      rs = RelayStatus(addr);
      _tempRelayStatusMap[addr] = rs;
    }

    return _doGenRelay(rs);
  }

  void cleanTempRelays() {
    List<String> needRemoveList = [];
    var now = DateTime.now().millisecondsSinceEpoch;
    for (var entry in _tempRelayStatusMap.entries) {
      var addr = entry.key;
      var status = entry.value;

      if (now - status.connectTime.millisecondsSinceEpoch > 1000 * 60 * 10 &&
          (status.lastNoteTime == null ||
              ((now - status.lastNoteTime!.millisecondsSinceEpoch) >
                  1000 * 60 * 10)) &&
          (status.lastQueryTime == null ||
              ((now - status.lastQueryTime!.millisecondsSinceEpoch) >
                  1000 * 60 * 10))) {
        // init time over 10 min
        // last note time over 10 min
        // last query time over 10 min
        needRemoveList.add(addr);
      }
    }

    for (var addr in needRemoveList) {
      // don't contain subscription, remote!
      _tempRelayStatusMap.remove(addr);
      nostr!.removeRelay(addr);
    }
  }
}
