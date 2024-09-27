import 'package:nowser/data/browser_history.dart';
import 'package:sqflite/sqflite.dart';

import 'db.dart';

class BrowserHistoryDB {
  static Future<int> insert(BrowserHistory o, {DatabaseExecutor? db}) async {
    db = await DB.getDB(db);
    return await db.insert("browser_history", o.toJson());
  }

  static Future<int?> total({DatabaseExecutor? db}) async {
    db = await DB.getDB(db);
    var sql = "select count(1) from browser_history";
    return Sqflite.firstIntValue(await db.rawQuery(sql));
  }

  static Future<List<BrowserHistory>> all({DatabaseExecutor? db}) async {
    List<BrowserHistory> objs = [];
    List<Object?>? arguments = [];
    db = await DB.getDB(db);
    var sql = "select * from browser_history order by created_at desc";
    List<Map<String, dynamic>> list = await db.rawQuery(sql, arguments);
    for (var i = 0; i < list.length; i++) {
      var json = list[i];
      objs.add(BrowserHistory.fromJson(json));
    }
    return objs;
  }

  static Future<void> deleteByIds(List<int> ids, {DatabaseExecutor? db}) async {
    var sql = "delete from browser_history where id in(";
    for (var id in ids) {
      sql += "?,";
    }
    sql = sql.substring(0, sql.length - 1);
    sql += ")";

    db = await DB.getDB(db);
    await db.execute(sql, ids);
  }
}
