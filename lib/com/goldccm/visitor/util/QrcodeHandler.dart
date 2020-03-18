import 'package:intl/intl.dart';
import 'package:visitor/com/goldccm/visitor/model/QrcodeMode.dart';
import 'package:visitor/com/goldccm/visitor/model/RoomOrderInfo.dart';
import 'package:visitor/com/goldccm/visitor/model/UserInfo.dart';
import 'package:visitor/com/goldccm/visitor/model/VisitInfo.dart';

import 'CommonUtil.dart';

/*
 * 二维码内容构造器
 */
class QrcodeHandler {

  /*
   *  构建二维码信息
   *  二维码类型1-员工门禁,2-访客门禁,3-身份证 4-会议室 5-茶室
   */
  static List<String> buildQrcodeData(QrcodeMode qrCodeMode){
    List<String> header = buildQrcodeComHeader(qrCodeMode);
    List<String> content;
    if(qrCodeMode.bitMapType==1){
      content= buildQrcodeBodyV3(qrCodeMode);
    }
    if(qrCodeMode.bitMapType==2){
      content = buildQrcodeBody(qrCodeMode);
    }else if(qrCodeMode.bitMapType==4||qrCodeMode.bitMapType==5){
      content = buildQrcodeBodyV2(qrCodeMode);
    }
    List<String> qrCodeMsg =[];
    for(var t=0;t<qrCodeMode.totalPages;t++){
      String qrCodeMsgTemp = header[t]+"|"+content[t];
      print("qrCodeString:$qrCodeMsgTemp");
      qrCodeMsg.add(qrCodeMsgTemp);
    }
    return qrCodeMsg;
  }

  /*
   * 二维码构造公共报文头
   */
  static List<String> buildQrcodeComHeader(QrcodeMode qrCodeMode){
    var qccodeType = qrCodeMode.bitMapType;//二维码类型1-员工门禁,2-访客门禁,3-身份证 4-会议室 5-茶室
    var totalPage = qrCodeMode.totalPages;//二维码显示的总页数
    String qrCodeHeader ="";
    List<String> qrCodeHeaderList = [];
    for(var i=0;i<totalPage;i++){
      qrCodeHeader = "abc"
          +"&"
          + qccodeType.toString()
          +"&"
          +totalPage.toString()
          +"&"
          +(i+1).toString()
          +"&"
          +CommonUtil.getCurrentTimeMinis();
      qrCodeHeaderList.add(qrCodeHeader);
    }
    return qrCodeHeaderList;
  }

  /*
   * type2 type3 公共报文体
   */
  static List<String> buildQrcodeBody(QrcodeMode qrCodeMode){
    UserInfo userInfo = qrCodeMode.userInfo;
    VisitInfo visitInfo = qrCodeMode.visitInfo;
    int totalPage = qrCodeMode.totalPages;
    List<String> qrContentList =[];
    String qrContent = '';
    if(visitInfo==null){
      qrContent = qrContent+'[]';
      qrContent = qrContent+'[]';
      qrContent = qrContent+'[]';
      qrContent = qrContent+'[]';
    }else{
      qrContent = (visitInfo.visitorRealName==null?qrContent+'[]':qrContent+'['+visitInfo.visitorRealName+']');
      qrContent = (visitInfo.id==null?qrContent+'[]':qrContent+'['+visitInfo.id+']');
      qrContent = (visitInfo.startDate==null?qrContent+'[]':qrContent+'['+DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(visitInfo.startDate))+']');
      qrContent = (visitInfo.endDate==null?qrContent+'[]':qrContent+'['+DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(visitInfo.endDate))+']');
    }
    int pageLength = qrContent.length ~/ totalPage;//每页文本内容
    for(var i=0;i<totalPage;i++){
      String contentTemp = '';
      if(i==totalPage-1){
        contentTemp = CommonUtil.encodeBase64(qrContent.substring(i*pageLength));
      }else{
        contentTemp = CommonUtil.encodeBase64(qrContent.substring(i*pageLength,(i+1)*pageLength));
      }
//      contentTemp = contentTemp+"|"+CommonUtil.getRandData(1, 1);
//      if(contentTemp.length<256){
//        String pageRight =CommonUtil.getRandData(1, 256-contentTemp.length);
//        print('$pageRight');
//        contentTemp = contentTemp+CommonUtil.getRandData(1, 256-contentTemp.length-26);
//      }
      qrContentList.add(contentTemp);
    }
    return qrContentList;
  }


  /*
   * type4 type5 公共报文体
   */
  static List<String> buildQrcodeBodyV2(QrcodeMode qrCodeMode){
    UserInfo userInfo = qrCodeMode.userInfo;
    RoomOrderInfo orderInfo = qrCodeMode.roomOrderInfo;
    int totalPage = qrCodeMode.totalPages;
    List<String> qrContentList =[];
    String qrContent = '';
    if(userInfo==null){
      qrContent = qrContent+'[]';
    }else{
      qrContent = (userInfo.realName==null?qrContent=qrContent+'[]':qrContent=qrContent+'['+userInfo.realName+']');
    }
    if(orderInfo==null){
      qrContent = qrContent+'[]';
      qrContent = qrContent+'[]';
      qrContent = qrContent+'[]';
      qrContent = qrContent+'[]';
    }else{
      print(orderInfo.toString());
      qrContent = (orderInfo.id==null?qrContent=qrContent+'[]':qrContent=qrContent+'['+orderInfo.id.toString()+']');
      qrContent = (orderInfo.createTime==null?qrContent=qrContent+'[]':qrContent=qrContent+'['+orderInfo.createTime.substring(0,10)+']');
      qrContent = (orderInfo.applyStartTime==null?qrContent=qrContent+'[]':qrContent=qrContent+'['+orderInfo.applyStartTime+"0"+']');
      qrContent = (orderInfo.applyEndTime==null?qrContent=qrContent+'[]':qrContent=qrContent+'['+orderInfo.applyEndTime+"0"+']');
    }
    int pageLength = qrContent.length ~/ totalPage;//每页文本内容
    for(var i=0;i<totalPage;i++){
      String contentTemp = '';
      if(i==totalPage-1){
        contentTemp = CommonUtil.encodeBase64(qrContent.substring(i*pageLength));
      }else{
        contentTemp = CommonUtil.encodeBase64(qrContent.substring(i*pageLength,(i+1)*pageLength));
      }
//      contentTemp = contentTemp+"|"+CommonUtil.getRandData(1, 1);
//      if(contentTemp.length<256){
//        String pageRight =CommonUtil.getRandData(1, 256-contentTemp.length);
//        print('$pageRight');
//        contentTemp = contentTemp+CommonUtil.getRandData(1, 256-contentTemp.length-26);
//      }
      qrContentList.add(contentTemp);
    }
    return qrContentList;

  }

  /*
   * type1 报文体
   */
  static List<String> buildQrcodeBodyV3(QrcodeMode qrCodeMode){
    UserInfo userInfo = qrCodeMode.userInfo;
    VisitInfo visitInfo = qrCodeMode.visitInfo;
    int totalPage = qrCodeMode.totalPages;
    List<String> qrContentList =[];
    String qrContent = '';
    print("qrcode:"+userInfo.toString());
    if(userInfo==null){
      qrContent = qrContent+'[]';
      qrContent = qrContent+'[]';
      qrContent = qrContent+'[]';
    }else{
      qrContent = (userInfo.realName==null?qrContent+'[]':qrContent+'['+userInfo.realName+']');
      qrContent = (userInfo.companyId==null?qrContent+'[]':qrContent+'['+userInfo.companyId.toString()+']');
      qrContent = (userInfo.id==null?qrContent+'[]':qrContent+'['+userInfo.id.toString()+']');
    }
    int pageLength = qrContent.length ~/ totalPage;//每页文本内容
    for(var i=0;i<totalPage;i++){
      String contentTemp = '';
      if(i==totalPage-1){
        contentTemp = CommonUtil.encodeBase64(qrContent.substring(i*pageLength));
      }else{
        contentTemp = CommonUtil.encodeBase64(qrContent.substring(i*pageLength,(i+1)*pageLength));
      }
//      contentTemp = contentTemp+"|"+CommonUtil.getRandData(1, 1);
//      if(contentTemp.length<256){
//        String pageRight =CommonUtil.getRandData(1, 256-contentTemp.length);
//        print('$pageRight');
//        contentTemp = contentTemp+CommonUtil.getRandData(1, 256-contentTemp.length-26);
//      }
      qrContentList.add(contentTemp);
    }
    return qrContentList;
  }

}