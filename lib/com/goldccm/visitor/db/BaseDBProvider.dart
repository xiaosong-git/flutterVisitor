import 'package:meta/meta.dart';
import 'package:sqflite/sqflite.dart';

import 'dbManager.dart';

/*
 * 数据表操作基类
 */

abstract class BaseDBProvider {
  bool isTableExist = false;

  tableSqlString();

  tableName();

  tableBaseString(String name,String primaryKey){
    return '''
    create table $name ( 
    $primaryKey integer primary key autoincrement,
    ''';
  }

  Future<Database> getDataBase () async{
    return await open();
  }

  @mustCallSuper
  prepare(String name,String creatSql) async{
    isTableExist = await DBManager.isTableExist(name);
    if(!isTableExist){
      Database db = await DBManager.getCurrentDatabase();
      return await db.execute(creatSql);
    }
  }

  @mustCallSuper
  open() async{
    if(!isTableExist){
      await prepare(tableName(), tableSqlString());
    }
    return await DBManager.getCurrentDatabase();
  }
}
