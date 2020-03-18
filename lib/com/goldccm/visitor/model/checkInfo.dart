class CheckInfo{

  int statisticsId;
  int userId;
  int groupId;
  String needCheckinDate;
  String needCheckinTime;
  int checkinType;
  String effictiveTime;

  CheckInfo({this.statisticsId,this.userId,this.groupId,this.needCheckinDate,this.needCheckinTime,this.checkinType,this.effictiveTime});

  CheckInfo.fromJson(Map json){
    this.statisticsId=json['statisticsId'];
    this.checkinType=json['checkinType'];
    this.groupId=json['groupId'];
    this.needCheckinTime=json['needCheckinTime'];
    this.needCheckinDate=json['needCheckinDate'];
    this.userId=json['userId'];
    this.effictiveTime=json['effictiveTime'];
  }
}