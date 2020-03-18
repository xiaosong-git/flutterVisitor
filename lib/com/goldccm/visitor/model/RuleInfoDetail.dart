class RuleInfoDetail{

  String userList;
  String whiteList;
  List<CheckInDate> checkInDate=List();
  List<LocInfo> locInfo=List();
  String groupName;
  int groupType;
  int companyId;

  RuleInfoDetail({this.userList,this.whiteList,this.checkInDate,this.groupType,this.groupName,this.companyId,this.locInfo});
}
class CheckInDate{
  int groupId;
  String workDays;
  String noneedOffwork;
  String timeInterval;
  CheckInDate({this.workDays,this.groupId,this.noneedOffwork,this.timeInterval});

  CheckInDate.fromJson(Map json){
    this.groupId=json['groupId'];
    this.timeInterval=json['timeInterval'];
    this.workDays=json['workDays'];
    this.noneedOffwork=json['noneedOffWork'];
  }
}
class LocInfo{
  int lat;
  int lng;
  String locTitle;
  String locDetail;
  String distance;
  LocInfo({this.locTitle,this.distance,this.lat,this.lng,this.locDetail});
  LocInfo.fromJson(Map json){
    this.lat=json['lat'];
    this.lng=json['lng'];
    this.locDetail=json['locDetail'];
    this.distance=json['distance'];
    this.locTitle=json['locTitle'];
  }
}