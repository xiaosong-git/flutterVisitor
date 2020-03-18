class CheckRecord{
  String time;
  String location;
  CheckRecord({this.time,this.location});
  CheckRecord.fromJson(Map json){
    this.location=json['location_detail'];
    this.time=json['checkin_time'];
  }
}