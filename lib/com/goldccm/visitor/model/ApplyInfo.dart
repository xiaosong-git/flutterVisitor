import 'package:meta/meta.dart';
import 'dart:convert';


class ApplyInfo{
    String id;
    String companyId;
    String sectionId;
    String userId;
    String userName;
    String createDate;
    String createTime;
    String roleType;
    String status;
    String companyName;
    String sectionName;

   ApplyInfo({
      this.id,
      this.companyId,
      this.sectionId,
      this.userId,
      this.userName,
      this.createDate,
      this.createTime,
      this.roleType,
      this.status,
      this.companyName,
      this.sectionName,
});

    ApplyInfo.fromJson(Map json){
       this.id=json['id'];
       this.companyId=json['companyId'];
       this.sectionId=json['sectionId'];
       this.userId=json['userId'];
       this.userName=json['userName'];
       this.createDate=json['createDate'];
       this.createTime=json['createTime'];
       this.roleType=json['roleType'];
       this.status=json['status'];
       this.companyName=json['companyName'];
       this.sectionName=json['sectionName'];
    }

}