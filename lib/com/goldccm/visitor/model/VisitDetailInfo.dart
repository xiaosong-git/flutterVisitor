import 'package:meta/meta.dart';
import 'dart:convert';


class VisitDetailInfo{

  String id;
  String userId;
  String visitorId;
  String recordType;
  String startDate;
  String endDate;
  String cStatus;
  String dateType;
  String visitDate;
  String visitTime;
  String replyDate;
  String replyTime;
  String companyName;
  String address;
  String sender;
  String receiver;
  String visitor;
  String visited;


  @override
  String toString() {
    return 'VisitDetailInfo{id: $id, userId: $userId, visitorId: $visitorId, recordType: $recordType, startDate: $startDate, endDate: $endDate, cStatus: $cStatus, dateType: $dateType, visitDate: $visitDate, visitTime: $visitTime, replyDate: $replyDate, replyTime: $replyTime, companyName: $companyName, address: $address, sender: $sender, receiver: $receiver, visitor: $visitor, visited: $visited}';
  }

  VisitDetailInfo({
    this.id,
    this.userId,
    this.visitorId,
    this.recordType,
    this.dateType,
    this.startDate,
    this.endDate,
    this.companyName,
    this.cStatus,
    this.address,
    this.replyDate,
    this.replyTime,
    this.visitDate,
    this.visitTime,
    this.visitor,
    this.receiver,
    this.sender,
    this.visited
  });

  VisitDetailInfo.fromJson(Map json) {
    id = json['id'].toString();
    userId = json['userId'].toString();
    visitorId = json['visitorId'].toString();
    recordType = json['recordType'].toString();
    cStatus = json['cstatus'];
    startDate = json['startDate'];
    endDate = json['endDate'];
    dateType = json['dateType'].toString();
    replyDate = json['replyDate'];
    replyTime = json['replyTime'];
    companyName = json['companyName'];
    address = json['addr'];
    visitDate = json['visitDate'];
    visitTime = json['visitTime'];
    sender = json['originator'];
    receiver = json['receiver'];
    visitor = json['visitor'];
    visited = json['visited'];
  }

}