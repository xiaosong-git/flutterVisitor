class RoomInfo<T>{

  int id;
  String roomName;
  int roomType;
  String roomIntro;
  String roomAddress;
  List<String> roomImage;
  String roomOpenTime;
  String roomCloseTime;
  String roomPrice;
  int roomSize;
  String roomManager;
  String roomStatus;
  String isOpen;
  String roomOrgCode;
  String roomCancelHour;
  String roomPercent;

  @override
  String toString() {
    return 'RoomInfo{id: $id, roomName: $roomName, roomType: $roomType, roomIntro: $roomIntro, roomAddress: $roomAddress, roomImage: $roomImage, roomOpenTime: $roomOpenTime, roomCloseTime: $roomCloseTime, roomPrice: $roomPrice, roomSize: $roomSize, roomManager: $roomManager, roomStatus: $roomStatus, roomOrgCode: $roomOrgCode, roomCancelHour: $roomCancelHour, roomPercent: $roomPercent}';
  }

  RoomInfo({this.id, this.roomName, this.roomType, this.roomIntro,this.roomAddress,
      this.roomImage, this.roomOpenTime, this.roomCloseTime, this.roomPrice,
      this.roomManager, this.roomStatus, this.roomOrgCode, this.roomCancelHour,
      this.roomPercent,this.roomSize,this.isOpen});

  RoomInfo.fromJson(Map json){
    this.id=json['id'];
    this.roomName=json['room_name'];
    this.roomType=json['room_type'];
    this.roomIntro=json['room_short_content'];
    this.roomImage=json['room_image'];
    this.roomOpenTime=json['room_open_time'];
    this.roomCloseTime=json['room_close_time'];
    this.roomPrice=json['room_price'];
    this.roomManager=json['room_manager'];
    this.roomStatus=json['room_status'];
    this.roomOrgCode=json['room_orgcode'];
    this.roomCancelHour=json['room_cancle_hour'];
    this.roomPercent=json['room_percent'];
  }
}