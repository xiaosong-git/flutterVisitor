class RuleInfo{

  String userList;
  int companyId;
  int groupType;
  String groupName;
  int groupId;
  int dateId;
  int dateCount;
  int locCount;
  String timeStr;
  String workDays;
  String time;
  String locTitle;

  RuleInfo({this.userList, this.companyId, this.groupType, this.groupName,
      this.groupId,this.dateCount,this.dateId,this.locCount,this.time,this.workDays,this.locTitle,this.timeStr});

  @override
  String toString() {
    return 'RuleInfo{userList: $userList, companyId: $companyId, groupType: $groupType, groupName: $groupName, groupId: $groupId, dateId: $dateId, dateCount: $dateCount, locCount: $locCount, workDays: $workDays, time: $time}';
  }
  RuleInfo.fromJson(Map json){
    this.groupId=json['groupId'];
    this.groupName=json['groupName'];
    this.dateId=json['dateId'];
    this.workDays=json['worddays'];
    this.time=json['time'];
    this.locTitle=json['locTitle'];
    this.dateCount=json['dateCount'];
    this.locCount=json['locCount'];
    this.timeStr=json['wk'];
  }
}