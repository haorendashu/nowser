import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nostr_sdk/event.dart';
import 'package:nostr_sdk/event_kind.dart';
import 'package:nostr_sdk/event_mem_box.dart';
import 'package:nostr_sdk/filter.dart';
import 'package:nostr_sdk/nip02/contact_list.dart';
import 'package:nostr_sdk/nip65/relay_list_metadata.dart';
import 'package:nostr_sdk/utils/later_function.dart';
import 'package:nostr_sdk/utils/string_util.dart';

import '../data/event_db.dart';
import '../data/metadata.dart';
import '../main.dart';

class UserinfoProvider extends ChangeNotifier with LaterFunction {
  Map<String, RelayListMetadata> _relayListMetadataCache = {};

  Map<String, Metadata> _metadataCache = {};

  Map<String, ContactList> _contactListMap = {};

  Map<String, int> _handingPubkeys = {};

  EventMemBox _penddingEvents = EventMemBox(sortAfterAdd: false);

  static UserinfoProvider? _userinfoProvider;

  static Future<UserinfoProvider> getInstance() async {
    if (_userinfoProvider == null) {
      _userinfoProvider = UserinfoProvider();
      // lazyTimeMS begin bigger and request less
      _userinfoProvider!.laterTimeMS = 2000;
    }

    return _userinfoProvider!;
  }

  Metadata? getMetadata(String pubkey, {bool loadData = true}) {
    var metadata = _metadataCache[pubkey];
    if (metadata != null) {
      return metadata;
    }

    if (loadData) {
      _handleDataNotfound(pubkey);
    }
    return null;
  }

  List<String> _checkingFromDBPubKeys = [];

  List<String> _needUpdatePubKeys = [];

  void _handleDataNotfound(String pubkey) {
    if (!_checkingFromDBPubKeys.contains(pubkey) &&
        !_handingPubkeys.containsKey(pubkey)) {
      _checkingFromDBPubKeys.add(pubkey);
      EventDB.list(
          [
            EventKind.METADATA,
            EventKind.RELAY_LIST_METADATA,
            EventKind.CONTACT_LIST,
          ],
          0,
          100,
          pubkeys: [pubkey]).then((eventList) {
        // print("${eventList.length} metadata find from db.");
        _penddingEvents.addList(eventList);
        if (eventList.length < 3) {
          _needUpdatePubKeys.add(pubkey);
        }
        _checkingFromDBPubKeys.remove(pubkey);
        later(_laterCallback);
      });
    }
  }

  void _laterCallback() {
    if (_needUpdatePubKeys.isNotEmpty) {
      _laterSearch();
    }

    if (!_penddingEvents.isEmpty()) {
      _handlePenddingEvents();
    }
  }

  void _handlePenddingEvents() {
    for (var event in _penddingEvents.all()) {
      _handingPubkeys.remove(event.pubkey);

      if (event.kind == EventKind.METADATA) {
        if (StringUtil.isBlank(event.content)) {
          continue;
        }

        // check cache
        var oldMetadata = _metadataCache[event.pubkey];
        if (oldMetadata == null) {
          // insert
          EventDB.insert(event);
          _eventToMetadataCache(event);
        } else if (oldMetadata.updated_at! < event.createdAt) {
          // update, remote old event and insert new event
          EventDB.execute("delete from event where kind = ? and pubkey = ?",
              [EventKind.METADATA, event.pubkey]);
          EventDB.insert(event);
          _eventToMetadataCache(event);
        }
      } else if (event.kind == EventKind.RELAY_LIST_METADATA) {
        // this is relayInfoMetadata, only set to cache, not update UI
        var oldRelayListMetadata = _relayListMetadataCache[event.pubkey];
        if (oldRelayListMetadata == null) {
          // insert
          EventDB.insert(event);
          _eventToRelayListCache(event);
        } else if (event.createdAt > oldRelayListMetadata.createdAt) {
          // update, remote old event and insert new event
          EventDB.execute("delete from event where kind = ? and pubkey = ?",
              [EventKind.RELAY_LIST_METADATA, event.pubkey]);
          EventDB.insert(event);
          _eventToRelayListCache(event);
        }
      } else if (event.kind == EventKind.CONTACT_LIST) {
        var oldContactList = _contactListMap[event.pubkey];
        if (oldContactList == null) {
          // insert
          EventDB.insert(event);
          _eventToContactList(event);
        } else if (event.createdAt > oldContactList.createdAt) {
          // update, remote old event and insert new event
          EventDB.execute(
              "delete from event where key_index = ? and kind = ? and pubkey = ?",
              [EventKind.CONTACT_LIST, event.pubkey]);
          EventDB.insert(event);
          _eventToContactList(event);
        }
      }
    }

    _penddingEvents.clear();
    notifyListeners();
  }

  void onEvent(Event event) {
    _penddingEvents.add(event);
    later(_laterCallback);
  }

  void _laterSearch() {
    if (_needUpdatePubKeys.isEmpty) {
      return;
    }

    // if (!nostr!.readable()) {
    //   // the nostr isn't readable later handle it again.
    //   later(_laterCallback, null);
    //   return;
    // }

    List<Map<String, dynamic>> filters = [];
    for (var pubkey in _needUpdatePubKeys) {
      {
        var filter = Filter(
          kinds: [
            EventKind.METADATA,
          ],
          authors: [pubkey],
          limit: 1,
        );
        filters.add(filter.toJson());
      }
      {
        var filter = Filter(
          kinds: [
            EventKind.RELAY_LIST_METADATA,
          ],
          authors: [pubkey],
          limit: 1,
        );
        filters.add(filter.toJson());
      }
      {
        var filter = Filter(
          kinds: [
            EventKind.CONTACT_LIST,
          ],
          authors: [pubkey],
          limit: 1,
        );
        filters.add(filter.toJson());
      }
      if (filters.length > 20) {
        nostr!.query(filters, onEvent);
        filters = [];
      }
    }
    if (filters.isNotEmpty) {
      nostr!.query(filters, onEvent);
    }

    for (var pubkey in _needUpdatePubKeys) {
      _handingPubkeys[pubkey] = 1;
    }
    _needUpdatePubKeys.clear();
  }

  void _eventToMetadataCache(Event event) {
    var jsonObj = jsonDecode(event.content);
    var md = Metadata.fromJson(jsonObj);
    md.pubkey = event.pubkey;
    md.updated_at = event.createdAt;
    _metadataCache[event.pubkey] = md;
  }

  void _eventToRelayListCache(Event event) {
    RelayListMetadata rlm = RelayListMetadata.fromEvent(event);
    _relayListMetadataCache[rlm.pubkey] = rlm;
  }

  void _eventToContactList(Event event) {
    var contactList = ContactList.fromJson(event.tags, event.createdAt);
    _contactListMap[event.pubkey] = contactList;
  }
}
