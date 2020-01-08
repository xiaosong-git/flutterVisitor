import 'package:sqflite/sqflite.dart';
import 'package:visitor/com/goldccm/visitor/db/ChatMessage.dart';
import 'package:visitor/com/goldccm/visitor/model/NoticeInfo.dart';
import 'BaseDBProvider.dart';

/*
 * 公告信息,公告记录Dao操作类
 */

class NoticeDao extends BaseDBProvider {
  //存储表明
  String table_name = "tbl_Notice";

  //主键
  String primary_Key = "_id";

  @override
  tableName() {
    return table_name;
  }

  //建表语句

  @override
  tableSqlString() {
    return tableBaseString(table_name, primary_Key) + '''
      N_ID  integer not null,
      N_OrgID  integer,
      N_RelationNo text,
      N_NoticeTitle text,
      N_Content text,
      N_CreateDate text,
      N_CreateTime text,
      N_Cstatus text,
      N_Status text
    )
    ''';
  }

  //插入一条消息

  Future insertNewMessage(NoticeInfo info) async {
    Database db = await getDataBase();
    return await db.insert(table_name, toMap(info));
  }

  //根据内容查找信息

  Future<List<ChatMessage>> queryMessage(String title) async {
    Database db = await getDataBase();
    List<Map<String, dynamic>> listRes = await db
        .query(table_name, where: 'N_NoticeTitle like %?%', whereArgs: [title]);
    if (listRes.length > 0) {
      List<ChatMessage> msgs = listRes.map((item) => ChatMessage.fromJson(item)).toList();
      return msgs;
    }
    return null;
  }

  //查询消息列表

  Future<List<NoticeInfo>> getMessageList() async {
    Database db = await getDataBase();
    List<Map<String, dynamic>> listRes = await db.query(table_name);
    if (listRes.length > 0) {
      List<NoticeInfo> infos = listRes.map((item) => NoticeInfo.fromJson(item)).toList();
      return infos;
    }
    return null;
  }

  //查询未读信息条数
  Future<int> getLatestMessageCount() async {
    Database db = await getDataBase();
    List<Map<String, dynamic>> listRes = await db.rawQuery(
        "select * from tbl_Notice where N_Status=not");
    if (listRes.length > 0) {
      List<ChatMessage> msgs = listRes.map((item) => ChatMessage.fromJson(item)).toList();
      return msgs.length;
    }
    return null;
  }
  //更新消息状态未读为已读
  Future updateMessageStatus() async {
    Database db = await getDataBase();
    int count = await db.rawUpdate(
        'update tbl_Notice set N_Status=been where N_status=not');
    return count;
  }
  //删除会话信息
  Future deleteSession() async {
    Database db = await getDataBase();
    int count = await db.rawDelete(
        'delete from tbl_Notice');
  }

  //消息转map
  Map<String, dynamic> toMap(NoticeInfo info) {
    Map<String, dynamic> map = {
    'N_ID' :info.id,
    'N_OrgID' :info.orgId,
    'N_RelationNo' :info.relationNo,
    'N_NoticeTitle' : info.noticeTitle,
    'N_Content' : info.content,
    'N_CreateDate': info.createDate,
    'N_CreateTime' : info.createTime,
    'N_Cstatus' :info.cstatus,
    };
    return map;
  }
}
