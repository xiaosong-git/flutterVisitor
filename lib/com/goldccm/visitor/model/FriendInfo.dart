/*
 * 好友信息
 */
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
      this.lastMessageId});

  FriendInfo.fromJson(Map map) {
    this.userId = map['userId'];
    this.name = map['name'];
    this.nickname = map['nickname'];
    this.remarkName = map['remarkName'];
    this.phone = map['phone'];
    this.realImageUrl = map['realImgUrl'];
    this.virtualImageUrl = map['virtualImageUrl'];
    this.companyName = map['companyName'];
    this.notice = map['notice'];
    this.firstZiMu = map['firstZiMu'];
    this.orgId = map['orgId'];
    this.imageServerUrl = map['imageServerUrl'];
    this.applyType = map['applyType'];
    this.lastMessageId = map['lastMessageId'];
  }

  @override
  String toString() {
    return 'FriendInfo{name: $name, nickname: $nickname, remarkName: $remarkName, phone: $phone, realImageUrl: $realImageUrl, virtualImageUrl: $virtualImageUrl, companyName: $companyName, notice: $notice, firstZiMu: $firstZiMu, orgId: $orgId, imageServerUrl: $imageServerUrl, applyType: $applyType, userId: $userId, lastMessageId: $lastMessageId}';
  }
}
