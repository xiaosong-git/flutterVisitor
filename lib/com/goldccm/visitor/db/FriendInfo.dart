/*
 * 好友信息
 */
import 'package:lpinyin/lpinyin.dart';

class FriendInfo {
  String name;
  String nickname;
  String remarkName;
  String phone;
  String realImageUrl;
  String virtualImageUrl;
  String companyName;
  String notice;
  String firstZiMu;
  String orgId;
  String imageServerUrl;
  int applyType;
  int userId;
  int lastMessageId;
  int belongId;

  FriendInfo(
      {this.name,
      this.nickname,
      this.remarkName,
      this.phone,
      this.realImageUrl,
      this.virtualImageUrl,
      this.companyName,
      this.notice,
      this.firstZiMu,
      this.orgId,
      this.imageServerUrl,
      this.applyType,
      this.userId,
      this.lastMessageId,
      this.belongId});

  FriendInfo.fromJson(Map map,int id) {
    this.userId = map['id'];
    this.name = map['realName'];
    this.nickname = map['nickName'];
    this.remarkName = map['remark'];
    this.phone = map['phone'];
    this.notice = map['notice'];
    this.realImageUrl = map['idHandleImgUrl'];
    this.virtualImageUrl = map['headImgUrl'];
    this.companyName = map['companyName'];
    this.notice = map['notice'];
    this.firstZiMu = map['firstZiMu'];
    this.orgId = map['orgId'].toString();
    this.imageServerUrl = map['imageServerUrl'];
    this.applyType = map['applyType'];
    this.lastMessageId = map['lastMessageId'];
    this.belongId = id;
    this.applyType = map['applyType'];
    this.firstZiMu = map['realName'] != null
        ? PinyinHelper.getFirstWordPinyin(map['realName'])
        .substring(0, 1)
        .toUpperCase()
        : "";
  }
  FriendInfo.fromData(Map map,int id) {
    this.userId = map['id'];
    this.name = map['realName'];
    this.nickname = map['nickName'];
    this.remarkName = map['nickName'];
    this.phone = map['phone'];
    this.notice = map['notice'];
    this.realImageUrl = map['idHandleImgUrl'];
    this.virtualImageUrl = map['virtualImageUrl'];
    this.companyName = map['companyName'];
    this.notice = map['notice'];
    this.firstZiMu = map['firstZiMu'];
    this.orgId = map['orgId'];
    this.imageServerUrl = map['imageServerUrl'];
    this.applyType = map['applyType'];
    this.lastMessageId = map['lastMessageId'];
    this.belongId = id;
    this.applyType = map['applyType'];
    this.firstZiMu = map['realName'] != null
        ? PinyinHelper.getFirstWordPinyin(map['realName'])
        .substring(0, 1)
        .toUpperCase()
        : "";
  }
  @override
  String toString() {
    return 'FriendInfo{name: $name, nickname: $nickname, remarkName: $remarkName, phone: $phone, realImageUrl: $realImageUrl, virtualImageUrl: $virtualImageUrl, companyName: $companyName, notice: $notice, firstZiMu: $firstZiMu, orgId: $orgId, imageServerUrl: $imageServerUrl, applyType: $applyType, userId: $userId, lastMessageId: $lastMessageId, belongId: $belongId}';
  }

}
