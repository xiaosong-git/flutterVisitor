/*
 * 地址信息
 */
class AddressInfo{
  int id;
  int companyId;
  int sectionId;
  int userId;
  int postId;
  String userName;
  String createDate;
  String createTime;
  String roleType;
  String status;
  String currentStatus;
  String sex;
  String secucode;
  String authtype;
  String companyName;
  String sectionName;
  String address;
  AddressInfo({
    this.id,this.companyId,this.sectionId,this.userId,this.postId,this.userName,this.createDate,this.createTime,this.roleType,this.status,this.currentStatus,this.sex,this.secucode,this.companyName,this.authtype,this.sectionName,this.address});
  AddressInfo.fromJson(Map json){
    this.id = json['id'];
    this.companyId = json['companyId'];
    this.sectionId = json['sectionId'];
    this.userId = json['userId'];
    this.userName = json['userName'];
    this.createDate = json['createDate'];
    this.createTime = json['createTime'];
    this.roleType = json['roleType'];
    this.status = json['status'];
    this.currentStatus = json['currentStatus'];
    this.status = json['status'];
    this.postId = json['postId'];
    this.companyName = json['companyName'];
    this.sectionName = json['sectionName'];
    this.address = json['addr'];
  }
}