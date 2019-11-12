import 'package:meta/meta.dart';
import 'dart:convert';


class VisitInfo{

   String id;
   String visitDate;
   String visitTime;
   String userId;
   String visitorId;
   String reason;
   String phone;
   String cstatus;
   String dateType;
   String startDate;
   String endDate;
   String recordType;
   String answerContent;
   String orgCode;
   String realName;
   String userRealName;
   String visitorRealName;
   String province;
   String orgName;
   String companyName;
   String city;
   int companyId;

   @override
   String toString() {
     return 'VisitInfo{id: $id, visitDate: $visitDate, visitTime: $visitTime, userId: $userId, visitorId: $visitorId, reason: $reason, phone: $phone, cstatus: $cstatus, dateType: $dateType, startDate: $startDate, endDate: $endDate, answerContent: $answerContent, orgCode: $orgCode, realName: $realName, userRealName: $userRealName, visitorRealName: $visitorRealName, province: $province, city: $city, orgName: $orgName, companyName: $companyName, companyId: $companyId}';
   }



  VisitInfo({
     this.id,
     this.visitDate,
     this.visitTime,
     this.userId,
     this.visitorId,
     this.reason,
     this.cstatus,
     this.dateType,
     this.startDate,
     this.endDate,
     this.answerContent,
     this.orgCode,
     this.realName,
     this.userRealName,
     this.visitorRealName,
     this.province,
     this.city,
     this.recordType,
     this.orgName,
     this.companyName,
     this.phone,
     this.companyId,
});

  VisitInfo.fromJson(Map json) {
    id = json['id'];
    visitDate = json['visitDate'];
    visitTime = json['visitTime'];
    userId = json['userId'];
    visitorId = json['visitorId'];
    reason = json['reason'];
    cstatus = json['cstatus'];
    dateType = json['dateType'];
    startDate = json['startDate'];
    endDate = json['endDate'];
    answerContent = json['answerContent'];
    orgCode = json['orgCode'];
    realName = json['realName'];
    userRealName = json['userRealName'];
    visitorRealName = json['visitorRealName'];
    province = json['province'];
    city = json['city'];
    recordType = json['recordType'];
    orgName = json['orgName'];
    companyName = json['companyName'];
    companyId = json['companyId'];
  }

}