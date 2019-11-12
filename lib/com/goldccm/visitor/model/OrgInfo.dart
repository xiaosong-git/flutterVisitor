import 'package:meta/meta.dart';
import 'dart:convert';

/*
 * 机构
 */
class OrgInfo{
   String id;
   String orgCode;
   String orgName;
   String sid;
   String istop;
   Object orgIcon;
   String relationNo;
   String sStatus;
   String orgType;
   String realName;
   String phone;
   String addr;
   String createDate;
   String province;
   String city;
   String area;

  OrgInfo({
     this.id,
     this.orgCode,
     this.orgName,
     this.sid,
     this.istop,
     this.orgIcon,
     this.relationNo,
     this.sStatus,
     this.orgType,
     this.realName,
     this.phone,
     this.addr,
     this.createDate,
     this.province,
     this.city,
     this.area,
});

   OrgInfo.fromJson(Map json){
     this.id=json['id'];
     this.orgCode=json['orgCode'];
     this.orgName=json['orgName'];
     this.sid=json['sid'];
     this.istop=json['istop'];
     this.orgIcon=json['orgIcon'];
     this.relationNo=json['relationNo'];
     this.sStatus=json['sStatus'];
     this.orgType=json['orgType'];
     this.realName=json['realName'];
     this.phone=json['phone'];
     this.addr=json['addr'];
     this.createDate=json['createDate'];
     this.province=json['province'];
     this.city=json['city'];
     this.area=json['area'];
   }

}