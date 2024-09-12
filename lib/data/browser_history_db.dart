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
}
