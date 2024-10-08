import 'package:nowser/data/auth_log.dart';
import 'package:sqflite/sqflite.dart';

import 'db.dart';

class AuthLogDB {
  static Future<List<AuthLog>> list(
      {DatabaseExecutor? db, int? appId, int? skip, int? limit}) async {
    List<AuthLog> objs = [];
    List<Object?>? arguments = [];
    db = await DB.getDB(db);
    var sql = "select * from auth_log where 1 = 1";
    if (appId != null) {
      sql += " and app_id = ?";
      arguments.add(appId);
    }
    sql += " order by created_at desc";
    if (skip != null && limit != null) {
      sql += " limit ?, ?";
      arguments.add(skip);
      arguments.add(limit);
    }
    List<Map<String, dynamic>> list = await db.rawQuery(sql, arguments);
    for (var i = 0; i < list.length; i++) {
      var json = list[i];
      objs.add(AuthLog.fromJson(json));
    }
    return objs;
  }

  static Future<int> insert(AuthLog o, {DatabaseExecutor? db}) async {
    db = await DB.getDB(db);
    return await db.insert("auth_log", o.toJson());
  }

  static Future<void> deleteByAppId(int appId, {DatabaseExecutor? db}) async {
    db = await DB.getDB(db);
    db.execute("delete from auth_log where app_id = ?", [appId]);
  }

  static Future<void> deleteByIds(List<int> ids, {DatabaseExecutor? db}) async {
    var sql = "delete from auth_log where id in(";
    for (var id in ids) {
      sql += "?,";
    }
    sql = sql.substring(0, sql.length - 1);
    sql += ")";

    db = await DB.getDB(db);
    db.execute(sql, ids);
  }
}
