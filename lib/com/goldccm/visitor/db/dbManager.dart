import 'package:sqflite/sqflite.dart';
import 'package:visitor/com/goldccm/visitor/util/CommonUtil.dart';

/*
 * 数据库操作管理类
 */
class DBManager {
  static const int _VERSION = 1; //数据库版本号

  static const String _DBNAME = "visitor_db.db"; //数据库名称

  static Database _dataBase; //数据库实例

  static init() async {
    var databasePath = await getDatabasesPath();
    String dbName = _DBNAME;
    String path = databasePath + dbName;
    if (CommonUtil.getAppPlat() == 'ios') {
      path = databasePath + "/" + dbName;
    }
    _dataBase = await openDatabase(path, version: _VERSION,
        onCreate: (Database db, int version) async {

    });
  }
  //获取当前数据库实例
  static Future<Database> getCurrentDatabase() async {
    if (_dataBase == null) {
      await init();
    }
    return _dataBase;
  }

//判断指定表是否已经存在

  static Future<bool> isTableExist(String tableName) async {
    await getCurrentDatabase();
    String sql =
        "select * from Sqlite_master where type ='table' and name = '$tableName' ";
    var res = await _dataBase.rawQuery(sql);
    return res != null && res.length > 0;
  }

//关闭数据库
  static void close() {
    _dataBase?.close();
    _dataBase = null;
  }
}
