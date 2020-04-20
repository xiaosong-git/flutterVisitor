class VisitData{
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
  String userRealName;
  String visitorRealName;
  String province;
  String orgName;
  String companyName;
  String city;
  int companyId;
  String address;

  VisitData(this.id, this.visitDate, this.visitTime, this.userId,
      this.visitorId, this.reason, this.phone, this.cstatus, this.dateType,
      this.startDate, this.endDate, this.recordType, this.answerContent,
      this.orgCode, this.userRealName, this.visitorRealName, this.province,
      this.orgName, this.companyName, this.city, this.companyId, this.address);

  @override
  String toString() {
    return 'VisitData{id: $id, visitDate: $visitDate, visitTime: $visitTime, userId: $userId, visitorId: $visitorId, reason: $reason, phone: $phone, cstatus: $cstatus, dateType: $dateType, startDate: $startDate, endDate: $endDate, recordType: $recordType, answerContent: $answerContent, orgCode: $orgCode, userRealName: $userRealName, visitorRealName: $visitorRealName, province: $province, orgName: $orgName, companyName: $companyName, city: $city, companyId: $companyId, address: $address}';
  }
  VisitData.fromMap(Map map){
    this.userId=map[userId];
  }
}