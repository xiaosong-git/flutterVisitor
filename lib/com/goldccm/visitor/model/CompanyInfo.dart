import 'dart:convert';
/*
 * 公司信息
 */
class CompanyInfo{

   String id;
   String companyCode;
   String companyName;
   String createDate;
   int createTime;
   String phone;
   int name;
   String applyType;
   String corporationID;
   String licenceNo;
   String addr;
   String orgId;


  CompanyInfo({
     this.id,
     this.companyCode,
     this.companyName,
     this.createDate,
     this.createTime,
     this.phone,
     this.name,
     this.applyType,
     this.corporationID,
     this.licenceNo,
     this.addr,
     this.orgId,
  });

  CompanyInfo.fromJson(Map json){
    this.id=json['id'];
    this.companyCode=json['companyCode'];
    this.companyName=json['companyName'];
    this.createDate=json['createDate'];
    this.createTime=json['createTime'];
    this.phone=json['phone'];
    this.name=json['name'];
    this.applyType=json['applyType'];
    this.corporationID=json['corporationID'];
    this.licenceNo=json['licenceNo'];
    this.addr=json['addr'];
    this.orgId=json['orgId'];
  }


}