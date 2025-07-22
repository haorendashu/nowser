import 'dart:convert';
import 'dart:developer';

import 'package:nostr_sdk/event.dart';
import 'package:nostr_sdk/utils/string_util.dart';
import 'package:sqflite/sqflite.dart';

import 'db.dart';

class EventDB {
  static Future<List<Event>> list(List<int> kinds, int skip, limit,
      {DatabaseExecutor? db, List<String>? pubkeys}) async {
    db = await DB.getDB(db);
    List<Event> l = [];
    List<dynamic> args = [];

    var sql = "select * from event where kind in(";
    for (var kind in kinds) {
      sql += "?,";
      args.add(kind);
    }
    sql = sql.substring(0, sql.length - 1);
    sql += ")";
    if (pubkeys != null && pubkeys.isNotEmpty) {
      if (pubkeys.length == 1) {
        sql += " and pubkey = ? ";
        args.add(pubkeys.first);
      } else {
        sql += " and pubkey in(";
        for (var pubkey in pubkeys) {
          sql += "?,";
          args.add(pubkey);
        }
        sql = sql.substring(0, sql.length - 1);
        sql += ")";
      }
    }

    sql += " order by created_at desc limit ?, ?";
    args.add(skip);
    args.add(limit);

    List<Map<String, dynamic>> list = await db.rawQuery(sql, args);
    for (var listObj in list) {
      l.add(loadFromJson(listObj));
    }
    return l;
  }

  static Future<int> insert(Event o, {DatabaseExecutor? db}) async {
    db = await DB.getDB(db);
    var jsonObj = o.toJson();
    var tags = jsonEncode(o.tags);
    jsonObj["tags"] = tags;
    jsonObj.remove("sig");
    try {
      return await db.insert("event", jsonObj);
    } catch (e) {
      return 0;
    }
  }

  static Future<Event?> get(String id, {DatabaseExecutor? db}) async {
    db = await DB.getDB(db);
    var list = await db.query("event", where: "id = ?", whereArgs: [id]);
    if (list.isNotEmpty) {
      return Event.fromJson(list[0]);
    }
  }

  static Future<Event?> execute(String sql, List<Object?> arguments,
      {DatabaseExecutor? db}) async {
    db = await DB.getDB(db);
    await db.execute(sql, arguments);
  }

  static Future<Event?> delete(String id, {DatabaseExecutor? db}) async {
    db = await DB.getDB(db);
    await db.execute("delete from event where id = ?", [id]);
  }

  static Future<void> deleteAll({DatabaseExecutor? db}) async {
    db = await DB.getDB(db);
    db.execute("delete from event ", []);
  }

  static Future update(Event o, {DatabaseExecutor? db}) async {
    db = await DB.getDB(db);
    var jsonObj = o.toJson();
    var tags = jsonEncode(o.tags);
    jsonObj["tags"] = tags;
    jsonObj.remove("sig");
    await db.update("event", jsonObj, where: "id = ?", whereArgs: [o.id]);
  }

  static Event loadFromJson(Map<String, dynamic> data) {
    Map<String, dynamic> m = {};
    m.addAll(data);

    var tagsStr = data["tags"];
    var tagsObj = jsonDecode(tagsStr);
    m["tags"] = tagsObj;
    m["sig"] = "";
    return Event.fromJson(m);
  }
}
