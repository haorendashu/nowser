import 'package:nostr_sdk/utils/db_util.dart';
import 'package:sqflite/sqflite.dart';

import '../const/base.dart';

class DB {
  static const _VERSION = 3;

  static const _dbName = "nowser.db";

  static Database? _database;

  static init() async {
    String path = await DBUtil.getPath(Base.APP_NAME, _dbName);
    print("path $path");

    try {
      _database = await openDatabase(path,
          version: _VERSION, onCreate: _onCreate, onUpgrade: _onUpgrade);
    } catch (e) {
      print("db open fail");
      print(e);
    }
  }

  static Future<void> _onCreate(Database db, int version) async {
    // init db
    db.execute(
        "create table app(id            integer not null constraint app_pk primary key autoincrement,pubkey        text    not null,app_type      integer not null,code          text    not null,name          text,image         text,connect_type  integer not null,always_allow  text,always_reject text,created_at    integer not null,updated_at    integer not null);");

    db.execute(
        "create table auth_log(id          integer not null constraint auth_log_pk primary key autoincrement,app_id      integer not null,auth_type   integer not null,event_kind  integer,title       text,content     text,auth_result integer not null,created_at  integer not null);");
    db.execute("create index auth_log_index on auth_log (app_id);");

    db.execute(
        "create table remote_signing_info(id                integer not null constraint remote_signing_info_pk primary key autoincrement,app_id            integer,local_pubkey      text,remote_pubkey      text,remote_signer_key text,relays            text,secret            text,created_at        integer,updated_at        integer);");

    db.execute(
        "create table zap_log(id         integer not null constraint zap_log_pk primary key autoincrement,app_id     integer not null constraint zap_log_index unique,zap_type   integer not null,num        integer not null,created_at integer not null);");
    db.execute("create index zap_log_index on zap_log (app_id);");

    db.execute(
        "create table bookmark(id             integer not null constraint bookmark_pk primary key autoincrement,title          text,url            text    not null,favicon        text,weight         integer,added_to_index integer, added_to_qa integer,created_at     integer);");
    db.execute(
        "create table browser_history(id         integer not null constraint browser_history_pk primary key autoincrement,title      text,url        text    not null,favicon    text,created_at integer);");

    db.execute(
        "create table event(id         text,pubkey     text,created_at integer,kind       integer,tags       text,content    text);");
    db.execute("create unique index event_key_index_id_uindex on event (id);");
    db.execute("create index event_date_index    on event (kind, created_at);");
  }

  static Future<void> _onUpgrade(
      Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      db.execute(
          "alter table bookmark add added_to_qa integer after added_to_index");
    }

    if (oldVersion < 3) {
      db.execute(
          "create table event(id         text,pubkey     text,created_at integer,kind       integer,tags       text,content    text);");
      db.execute(
          "create unique index event_key_index_id_uindex on event (id);");
      db.execute(
          "create index event_date_index    on event (kind, created_at);");
    }
  }

  static Future<Database> getCurrentDatabase() async {
    if (_database == null) {
      await init();
    }
    return _database!;
  }

  static Future<DatabaseExecutor> getDB(DatabaseExecutor? db) async {
    if (db != null) {
      return db;
    }
    return getCurrentDatabase();
  }

  static void close() {
    _database?.close();
    _database = null;
  }

  static Future<void> deleteByIds(String tableName, List<int> ids,
      {DatabaseExecutor? db}) async {
    var sql = "delete from $tableName where id in(";
    for (var id in ids) {
      sql += "?,";
    }
    sql = sql.substring(0, sql.length - 1);
    sql += ")";

    db = await DB.getDB(db);
    await db.execute(sql, ids);
  }
}
