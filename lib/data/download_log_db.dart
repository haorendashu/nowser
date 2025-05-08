import 'package:nowser/data/download_log.dart';
import 'package:sqflite/sqflite.dart';

import 'db.dart';

class DownloadLogDB {
  static Future<int?> total({DatabaseExecutor? db}) async {
    db = await DB.getDB(db);
    var sql = "select count(1) from download_log";
    return Sqflite.firstIntValue(await db.rawQuery(sql));
  }

  static Future<int> insert(DownloadLog o, {DatabaseExecutor? db}) async {
    db = await DB.getDB(db);
    return await db.insert("download_log", o.toJson());
  }

  static Future<List<DownloadLog>> all({DatabaseExecutor? db}) async {
    List<DownloadLog> objs = [];
    List<Object?>? arguments = [];
    db = await DB.getDB(db);
    var sql = "select * from download_log order by created_at desc";
    List<Map<String, dynamic>> list = await db.rawQuery(sql, arguments);
    for (var i = 0; i < list.length; i++) {
      var json = list[i];
      objs.add(DownloadLog.fromJson(json));
    }
    return objs;
  }

  static Future<void> deleteByIds(List<int> ids, {DatabaseExecutor? db}) async {
    await DB.deleteByIds("download_log", ids, db: db);
  }
}
