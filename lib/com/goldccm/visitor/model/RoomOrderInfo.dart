class RoomOrderInfo<T>{
  int id;
  int roomID;
  int applyUserID;
  String applyDate;
  String applyStartTime;
  String applyEndTime;
  String timeInterval;
  int recordStatus;
  String createTime;
  String cancelTime;
  String roomName;
  int roomType;
  int roomSize;
  String roomIntro;
  String roomAddress;
  String roomImage;
  String price;
  String tradeNO;
  String tradeStatus;
  int gate;

  RoomOrderInfo({this.id, this.roomID, this.applyUserID, this.applyDate,this.roomSize,
    this.applyStartTime, this.applyEndTime, this.timeInterval, this.recordStatus,
    this.createTime, this.cancelTime,this.roomName,this.roomType,this.roomIntro,this.roomAddress,this.roomImage,this.price,this.tradeNO,this.tradeStatus,this.gate});

  RoomOrderInfo.fromJson(Map json){
    this.id=json['id'];
    this.roomID=json['room_id'];
    this.applyUserID=json['apply_userid'];
    this.applyDate=json['apply_date'];
    this.applyStartTime=json['apply_start_time'];
    this.applyEndTime=json['apply_end_time'];
    this.timeInterval=json['time_interval'];
    this.recordStatus=json['record_status'];
    this.createTime=json['create_time'];
    this.cancelTime=json['cancle_time'];
  }

  @override
  String toString() {
    return 'RoomOrderInfo{id: $id, roomID: $roomID, applyUserID: $applyUserID, applyDate: $applyDate, applyStartTime: $applyStartTime, applyEndTime: $applyEndTime, timeInterval: $timeInterval, recordStatus: $recordStatus, createTime: $createTime, cancelTime: $cancelTime, roomName: $roomName, roomType: $roomType, roomSize: $roomSize, roomIntro: $roomIntro, roomAddress: $roomAddress, roomImage: $roomImage, price: $price, tradeNO: $tradeNO, tradeStatus: $tradeStatus, gate: $gate}';
  }
}