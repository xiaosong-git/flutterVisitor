import 'package:meta/meta.dart';
import 'dart:convert';

class UserInfo{
   int id;
   num orgId;
   String relationNo;
   String realName; //真实姓名
   String nickName; //昵称
   String loginName; //登录账号
   String idType; //证件类型 默认就是身份证 01
   String idNO; //证件号 用密钥加密，取出来再解密
   String phone; //联系手机号
   String createDate; //建立日期  yyyy-MM-dd
   String createTime; //建立时间 HH:mm:ss
   String province; //省
   String city; //市
   String area; //县
   String addr; //地址
   String isAuth = "F"; //是否实名 F:未实名 T:实名
   String failReason;
   String authDate; //实名日期 yyyy-MM-dd
   String authTime; //实名时间 HH:mm:ss
   String idFrontImgUrl; //证件正面照
   String idOppositeImgUrl; //证件反面照
   String idHandleImgUrl; //手持证件照
   String bankCardImgUrl; //银行卡正面照
   String workKey;
   String headImgUrl;
   String token;
   String userName;
   String qrcodeUrl;
   num companyId;
   String soleCode;
   String validityDate;
   String companyName;
   String visitorId;
   String lastLoginTime;
   String isGestureOpened; //是否启用手势密码 F:未启用 T:启用
   String ufId;
   String sortLetters;
   bool hasApplyPermission=false;

   UserInfo({this.id, this.orgId, this.relationNo, this.realName, this.nickName,
       this.loginName, this.idType, this.idNO, this.phone, this.createDate,
       this.createTime, this.province, this.city, this.area, this.addr,
       this.isAuth, this.failReason, this.authDate, this.authTime,
       this.idFrontImgUrl, this.idOppositeImgUrl, this.idHandleImgUrl,
       this.bankCardImgUrl, this.workKey, this.headImgUrl, this.token,
       this.userName, this.qrcodeUrl, this.companyId, this.soleCode,
       this.validityDate, this.companyName, this.visitorId, this.lastLoginTime,
       this.isGestureOpened, this.ufId, this.sortLetters,
       this.hasApplyPermission});

   UserInfo.fromJson(var json) {
      id = json['id'];
      orgId = json['orgId'];
      relationNo = json['relationNo'];
      realName = json['realName'];
      nickName = json['nickName'];
      loginName = json['loginName'];
      idType = json['idType'];
      idNO = json['idNO'];
      phone = json['phone'];
      createDate = json['createDate'];
      createTime = json['createTime'];
      province = json['province'];
      city = json['city'];
      area = json['area'];
      addr = json['addr'];
      isAuth = json['isAuth'];
      failReason = json['failReason'];
      authDate = json['authDate'];
      authTime = json['authTime'];
      idFrontImgUrl = json['idFrontImgUrl'];
      idOppositeImgUrl = json['idOppositeImgUrl'];
      idHandleImgUrl = json['idHandleImgUrl'];
      bankCardImgUrl = json['bankCardImgUrl'];
      workKey = json['workKey'];
      headImgUrl = json['headImgUrl'];
      token = json['token'];
      userName = json['userName'];
      qrcodeUrl = json['qrcodeUrl'];
      companyId = json['companyId'];
      soleCode = json['soleCode'];
      validityDate= json['validityDate'];
      companyName= json['companyName'];
      visitorId= json['visitorId'];
      lastLoginTime= json['lastLoginTime'];
      isGestureOpened= json['isGestureOpened'];
      ufId= json['ufId'] ;
      sortLetters= json['sortLetters'];
      hasApplyPermission= json['hasApplyPermission'];
   }

   @override
   String toString() {
      return 'UserInfo{id: $id, orgId: $orgId, relationNo: $relationNo, realName: $realName, nickName: $nickName, loginName: $loginName, idType: $idType, idNO: $idNO, phone: $phone, createDate: $createDate, createTime: $createTime, province: $province, city: $city, area: $area, addr: $addr, isAuth: $isAuth, failReason: $failReason, authDate: $authDate, authTime: $authTime, idFrontImgUrl: $idFrontImgUrl, idOppositeImgUrl: $idOppositeImgUrl, idHandleImgUrl: $idHandleImgUrl, bankCardImgUrl: $bankCardImgUrl, workKey: $workKey, headImgUrl: $headImgUrl, token: $token, userName: $userName, qrcodeUrl: $qrcodeUrl, companyId: $companyId, soleCode: $soleCode, validityDate: $validityDate, companyName: $companyName, visitorId: $visitorId, lastLoginTime: $lastLoginTime, isGestureOpened: $isGestureOpened, ufId: $ufId, sortLetters: $sortLetters, hasApplyPermission: $hasApplyPermission}';
   }


}
