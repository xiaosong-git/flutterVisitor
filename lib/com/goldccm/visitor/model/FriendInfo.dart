/*
 * 好友信息
 */
class FriendInfo{
  String name;
  String nickname;
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

  FriendInfo(
      {this.name,
        this.nickname,
        this.phone,
        this.realImageUrl,
        this.virtualImageUrl,
        this.firstZiMu,
        this.applyType,
        this.orgId,
        this.imageServerUrl,
        this.notice,
        this.companyName,
        this.userId});
}