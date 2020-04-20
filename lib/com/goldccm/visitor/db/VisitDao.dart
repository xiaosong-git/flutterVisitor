import 'package:sqflite/sqflite.dart';
import 'package:visitor/com/goldccm/visitor/db/FriendInfo.dart';
import 'BaseDBProvider.dart';

// 访问记录操作类
class VisitDao extends BaseDBProvider {
  //表明
  String thisTableName = "tbl_Visit";

  //主键
  String primaryKey = "V_ID";

  @override
  tableName() {
    return thisTableName;
  }

  //建表语句
  @override
  tableSqlString() {
    return tableBaseString(thisTableName, primaryKey) + '''
    visit_date text,
    visit_time text,
    from_id text,
    to_id text,
    reason text,
    status text,
    date_type text,
    start_date text,
    end_date text,
    record_type text,
    answer_content text,
    org_code text,
    from_realname text,
    to_realname text,
    province text,
    org_name text,
    company_name text,
    city text,
    company_id text,
    address text
    )
    ''';
  }
  //增
    visitInsert() async {
      Database db=await getDataBase();
    }
  //删
    visitDelete() async {
      Database db=await getDataBase();
    }
  //改
    visitUpdate() async {
      Database db=await getDataBase();
    }
  //查
    visitQuery() async {
      Database db=await getDataBase();
    }
}
