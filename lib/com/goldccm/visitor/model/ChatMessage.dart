/*
 * 聊天信息体
 */
class ChatMessage {

  int M_ID;
  String M_MessageContent;
  String M_Status;
  String M_Time;
  String M_MessageType;
  String M_IsSend;
  int M_userId;
  int M_FriendId;
  String M_FnickName;
  String M_FrealName;
  String M_FheadImgUrl;
  int M_visitId;
  String M_orgId;
  String M_StartDate;
  String M_EndDate;
  String M_orgName;
  String M_companyName;
  String M_province;
  String M_city;
  String M_cStatus;
  String M_recordType;
  String M_answerContent;
  int unreadCount;
  int M_isSended;
  ChatMessage(
      {this.M_ID,
      this.M_MessageContent,
      this.M_Status,
      this.M_Time,
      this.M_MessageType,
      this.M_IsSend,
      this.M_userId,
      this.M_FriendId,
      this.M_FnickName,
      this.M_FrealName,
      this.M_FheadImgUrl,
      this.unreadCount,
      this.M_StartDate,
      this.M_EndDate,
      this.M_orgName,
        this.M_orgId,
      this.M_companyName,
      this.M_city,
      this.M_province,
      this.M_cStatus,
      this.M_visitId,
      this.M_answerContent,
      this.M_recordType,
      this.M_isSended});

  ChatMessage.fromJson(Map map) {
    this.M_ID = map['M_ID'];
    this.M_MessageContent = map['M_MessageContet'];
    this.M_Status = map['M_Status'];
    this.M_Time = map['M_Time'];
    this.M_MessageType = map['M_MessageType'];
    this.M_IsSend = map['M_IsSend'];
    this.M_userId = map['M_userId'];
    this.M_FriendId = map['M_FriendId'];
    this.M_FnickName = map['M_FnickName'];
    this.M_FrealName = map['M_FrealName'];
    this.M_FheadImgUrl = map['M_FheadImgUrl'];
    this.unreadCount = map['unreadCount'];
    this.M_visitId = map['M_visitId'];
    this.M_StartDate = map['M_StartDate'];
    this.M_EndDate = map['M_EndDate'];
    this.M_orgName = map['M_orgName'];
    this.M_companyName = map['M_companyName'];
    this.M_city = map['M_city'];
    this.M_orgId = map['M_orgId'];
    this.M_province = map['M_province'];
    this.M_cStatus = map['M_cStatus'];
    this.M_answerContent = map['M_answerContent'];
    this.M_recordType = map['M_recordType'];
    this.M_isSended = map['M_isSended'];
  }

  @override
  String toString() {
    return 'ChatMessage{M_ID: $M_ID, M_MessageContent: $M_MessageContent, M_Status: $M_Status, M_Time: $M_Time, M_MessageType: $M_MessageType, M_IsSend: $M_IsSend, M_userId: $M_userId, M_FriendId: $M_FriendId, M_FnickName: $M_FnickName, M_FrealName: $M_FrealName, M_FheadImgUrl: $M_FheadImgUrl, M_visitId: $M_visitId, M_orgId: $M_orgId, M_StartDate: $M_StartDate, M_EndDate: $M_EndDate, M_orgName: $M_orgName, M_companyName: $M_companyName, M_province: $M_province, M_city: $M_city, M_cStatus: $M_cStatus, M_recordType: $M_recordType, M_answerContent: $M_answerContent, unreadCount: $unreadCount, M_isSended: $M_isSended}';
  }

}
