import 'package:meta/meta.dart';
import 'package:visitor/com/goldccm/visitor/model/UserInfo.dart';
import 'package:visitor/com/goldccm/visitor/model/VisitInfo.dart';

import 'RoomOrderInfo.dart';

/*
 定义如下
 userInfo 用户信息
 visitInfo 访问信息(用于员工和访问进出门)
 bitMapType 访问类型 1 - 员工门禁,2 - 访客门禁,3 - 身份证 4 - 会议室 5 - 茶室
 totalPages 二维码的数量
 orderInfo 订单信息(用于各类订单支付的现场确认)
 */
class QrcodeMode{

   UserInfo userInfo;
   int totalPages;
   VisitInfo visitInfo;
   int bitMapType;
   RoomOrderInfo roomOrderInfo;
   QrcodeMode({this.userInfo,this.totalPages,this.visitInfo,this.bitMapType,this.roomOrderInfo});

}