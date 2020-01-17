import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:sqflite/sqflite.dart';
import 'package:visitor/com/goldccm/visitor/db/ChatMessage.dart';
import 'package:visitor/com/goldccm/visitor/db/FriendInfo.dart';
import 'BaseDBProvider.dart';

/*
 * 聊天信息,聊天记录Dao操作类
 */

class FriendDao extends BaseDBProvider {
  //存储表明
  String table_name = "tbl_Friend";

  //主键
  String primary_Key = "F_ID";

  @override
  tableName() {
    return table_name;
  }

  //建表语句
  @override
  tableSqlString() {
    return tableBaseString(table_name, primary_Key) + '''
    realName text,
    nickName text,
    phone text,
    realImgUrl text,
    virtualImageUrl text,
    companyName text,
    notice text,
    firstZiMu text,
    orgId text,
    imageServerUrl text,
    applyType int,
    userId int,
    lastMessageId int,
    belongId int
    )
    ''';
  }

  //插入单条好友记录
  Future<int> insertFriendInfo(FriendInfo info) async {
    Database db = await getDataBase();
    return await db.insert(table_name, toMap(info));
  }
  //插入单条好友记录
  Future<int> updateFriendInfo(FriendInfo info) async {
    Database db = await getDataBase();
    return await db.update(table_name,toMap(info),where:  'userId = ? ',whereArgs: [info.userId]);
  }
  //通过用户id获取单条好友记录
  Future<FriendInfo> querySingle(int userId) async {
    Database db = await getDataBase();
    List<Map> listRes = await db.query(table_name,where: 'userId = ? ',whereArgs: [userId]);
    if(listRes.length>0){
       List<FriendInfo> msgs= listRes.map((item) => FriendInfo.fromJson(item)).toList();
       return msgs[0];
    }
    return null;
  }
  //获取好友列表
  Future<List<FriendInfo>> getFriendInfo(int belongId) async {
    Database db = await getDataBase();
    List<Map<String, dynamic>> listRes = await db.query(table_name,where: 'belongId = ? ',whereArgs: [belongId]);
    if (listRes.length > 0) {
      List<FriendInfo> msgs =
      listRes.map((item) => FriendInfo.fromJson(item)).toList();
      return msgs;
    }
    return null;
  }
  //判断当前是否存在
  Future<bool> isExist(int userID) async {
    Database db = await getDataBase();
    String sql="select * from $table_name where userId=?";
    List<Map<String, dynamic>> listRes=await db.rawQuery(sql,[userID]);
    if(listRes.length>0){
      return true;
    }
    return false;
  }
  //消息转map
  Map<String, dynamic> toMap(FriendInfo info) {
    Map<String, dynamic> map = {
      'realName':info.name,
      'nickName':info.nickname,
      'phone':info.phone,
      'realImgUrl':info.realImageUrl,
      'virtualImageUrl':info.virtualImageUrl,
      'companyName':info.companyName,
      'notice':info.notice,
      'firstZiMu':info.firstZiMu,
      'orgId':info.orgId,
      'imageServerUrl':info.imageServerUrl,
      'applyType':info.applyType,
      'userId':info.userId,
      'lastMessageId':info.lastMessageId,
      'belongId':info.belongId,
    };
    return map;
  }
}
