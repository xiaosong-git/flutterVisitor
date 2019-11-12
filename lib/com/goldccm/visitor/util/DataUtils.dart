import 'package:visitor/com/goldccm/visitor/model/UserInfo.dart';
import 'package:visitor/com/goldccm/visitor/model/NoticeInfo.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DataUtils {
  static final String SP_AC_TOKEN = "accessToken";
  static final String SP_IS_LOGIN = "isLogin"; // SP_IS_LOGIN标记是否登录
  static final String SP_USER_ID = "userid";
  //需保存的用户信息
  static final String SP_ID = "USERID";
  static final String SP_ORGID = "ORGID";
  static final String SP_REALNAME = "REALNAME";
  static final String SP_LOGINNAME = "LOGINNAME";
  static final String SP_IDTYPE = "IDTYPE";
  static final String SP_IDNO = "IDNO";
  static final String SP_PHONE = "PHONE";
  static final String SP_ISAUTH = "ISAUTH";
  static final String SP_TOKEN = "TOKEN";
  static final String SP_ISSETTRANSPWD = "ISSETTRANSPWD";
  static final String SP_COMPANYID = "COMPANYID";
  static final String SP_WORKKEY = "WORKKEY";
  static final String SP_COMPANYNAME = "COMPANYNAME";
  static final String SP_IDHANDLEIMGURL = "IDHANDLEIMGURL";
  static final String SP_HEADIMGURL = "HEADIMGURL";
  static final String SP_DEVICETOKEN ="DEVICETOKEN";
  //需保存的提示信息
  static final String SP_NOTICE_TITLE = "TITLE";
  static final String SP_NOTICE_CONTENT = "CONTENT";

  static saveLoginInfo(Map data) async {
    if (data != null) {
      SharedPreferences sp = await SharedPreferences.getInstance();
      String accessToken = data['token'];
      num userId = data['id'];
      await sp.setInt(SP_USER_ID, userId); //用户ID
      await sp.setString(SP_AC_TOKEN, accessToken); //登录token
      await sp.setBool(SP_IS_LOGIN, true); // SP_IS_LOGIN标记是否登录
    }
  }

  /*
  保存用户信息
   */
  static Future<UserInfo> saveUserInfo(Map data) async{
    if (data != null) {
      SharedPreferences sp;
      await SharedPreferences.getInstance().then((value) {
        sp = value;
      });
      int id = data['id'];
      num orgId = data['orgId'];
      String relationNo = data['relationNo'];
      String realName = data['realName'];
      String nickName = data['niceName'];
      String loginName = data['loginName'];
      String idType = data['idType'];
      String idNO = data['idNO'];
      String phone = data['phone'];
      String createDate = data['createDate'];
      String createTime = data['createTime'];
      String province = data['province'];
      String city = data['city'];
      String area = data['area'];
      String addr = data['addr'];
      String isAuth = data['isAuth'];
      String authDate = data['authDate'];
      String authTime = data['authTime'];
      String idFrontImgUrl = data['idFrontImgUrl'];
      String idOppositeImgUrl = data['idOppositeImgUrl'];
      String idHandleImgUrl = data['idHandleImgUrl'];
      String bankCardImgUrl = data['bankCardImgUrl'];
      String headImgUrl = data['headImgUrl'];
      String token = data['token'];
      String isSetTransPwd = data['isSetTransPwd'];
      String qrcodeUrl = data['qrcodeUrl'];
      int companyId = data['companyId'];
      String role = data['role'];
      String workKey = data['workKey'];
      String failReason = data['failReason'];
      String soleCode = data['soleCode'];
      String validityDate = data['validityDate'];
      String companyName = data['companyName'];
      await sp.setInt(SP_ORGID, orgId);
      await sp.setString(SP_REALNAME, realName);
      await sp.setString(SP_LOGINNAME, loginName);
      await sp.setString(SP_IDTYPE, idType);
      await sp.setString(SP_IDNO, idNO);
      await sp.setString(SP_PHONE, phone);
      await sp.setString(SP_ISAUTH, isAuth);
      await sp.setString(SP_TOKEN, token);
      await sp.setString(SP_HEADIMGURL, headImgUrl);
      await sp.setString(SP_ISSETTRANSPWD, isSetTransPwd);
      await sp.setInt(SP_COMPANYID, companyId);
      await sp.setInt(SP_ID, id);
      await sp.setString(SP_WORKKEY, workKey);
      await sp.setString(SP_COMPANYNAME, companyName);
      await sp.setString(SP_IDHANDLEIMGURL, idHandleImgUrl);

      UserInfo userInfo = new UserInfo(
        id: id,
        orgId: orgId,
        relationNo: relationNo,
        realName: realName,
        nickName: nickName,
        loginName: loginName,
        idType: idType,
        idNO: idNO,
        phone: phone,
        createDate: createDate,
        createTime: createTime,
        province: province,
        city: city,
        addr: addr,
        isAuth: isAuth,
        authDate: authDate,
        authTime: authTime,
        idFrontImgUrl: idFrontImgUrl,
        idOppositeImgUrl: idOppositeImgUrl,
        idHandleImgUrl: idHandleImgUrl,
        bankCardImgUrl: bankCardImgUrl,
        headImgUrl: headImgUrl,
        token: token,
        qrcodeUrl: qrcodeUrl,
        companyId: companyId,
        workKey: workKey,
        failReason: failReason,
        soleCode: soleCode,
        validityDate: validityDate,
        companyName: companyName,
      );
      return userInfo;
    }
    return null;
  }
  /*
  更新用户信息
   */
  static Future<UserInfo> updateUserInfo(UserInfo data) async{
    if (data != null) {
      SharedPreferences sp;
      await SharedPreferences.getInstance().then((value) {
        sp = value;
      });
      int id = data.id;
      num orgId = data.orgId;
      String relationNo = data.relationNo;
      String realName = data.realName;
      String nickName = data.nickName;
      String loginName = data.loginName;
      String idType = data.idType;
      String idNO = data.idNO;
      String phone = data.phone;
      String createDate = data.createDate;
      String createTime = data.createTime;
      String province = data.province;
      String city = data.city;
      String area = data.area;
      String addr = data.addr;
      String isAuth = data.isAuth;
      String authDate = data.authDate;
      String authTime = data.authTime;
      String idFrontImgUrl = data.idFrontImgUrl;
      String idOppositeImgUrl = data.idOppositeImgUrl;
      String idHandleImgUrl = data.idHandleImgUrl;
      String bankCardImgUrl = data.bankCardImgUrl;
      String headImgUrl = data.headImgUrl;
      String token = data.token;
      await sp.setInt(SP_ORGID, orgId);
      await sp.setString(SP_REALNAME, realName);
      await sp.setString(SP_LOGINNAME, loginName);
      await sp.setString(SP_IDTYPE, idType);
      await sp.setString(SP_IDNO, idNO);
      await sp.setString(SP_PHONE, phone);
      await sp.setString(SP_ISAUTH, isAuth);
      await sp.setString(SP_TOKEN, token);
      await sp.setString(SP_HEADIMGURL, headImgUrl);
      await sp.setInt(SP_ID, id);
      await sp.setString(SP_IDHANDLEIMGURL, idHandleImgUrl);

      UserInfo userInfo = new UserInfo(
        id: id,
        orgId: orgId,
        relationNo: relationNo,
        realName: realName,
        nickName: nickName,
        loginName: loginName,
        idType: idType,
        idNO: idNO,
        phone: phone,
        createDate: createDate,
        createTime: createTime,
        province: province,
        city: city,
        addr: addr,
        isAuth: isAuth,
        authDate: authDate,
        authTime: authTime,
        idFrontImgUrl: idFrontImgUrl,
        idOppositeImgUrl: idOppositeImgUrl,
        idHandleImgUrl: idHandleImgUrl,
        bankCardImgUrl: bankCardImgUrl,
        headImgUrl: headImgUrl,
        token: token,
      );
      return userInfo;
    }
    return null;
  }

  /*
  保存用户的消息信息
   */
  static Future<NoticeInfo> saveNoticeInfo(Map data) async {
    if (data != null) {
      SharedPreferences sp = await SharedPreferences.getInstance();
      num id = data['id'];
      num orgId = data['orgId'];
      String relationNo = data['relationNo'];
      String noticeTitle = data['noticeTitle'];
      String content = data['content'];
      String createDate = data['createDate'];
      String createTime = data['createTime'];
      String cstatus = data['cstatus'];
      sp.setString("SP_NOTICE_TITLE", noticeTitle);
      sp.setString("SP_NOTICE_CONTENT", content);
      NoticeInfo notice = new NoticeInfo(
          id: id,
          orgId: orgId,
          relationNo: relationNo,
          noticeTitle: noticeTitle,
          content: content,
          createDate: createDate,
          createTime: createTime,
          cstatus: cstatus);
      return notice;
    }

    return null;
  }

  static Future<UserInfo> getUserInfo()async{
    SharedPreferences sp;
    await SharedPreferences.getInstance().then((value) {
      sp = value;
    });
    bool isLogin = sp.getBool(SP_IS_LOGIN);
    if (isLogin == null||!isLogin) {
      return null;
    }
    UserInfo userInfo = new UserInfo();
    userInfo.orgId =  sp.getInt(SP_ORGID);
    userInfo.realName =  sp.getString(SP_REALNAME);
    userInfo.loginName = sp.getString(SP_LOGINNAME);
    userInfo.idType = sp.getString(SP_IDTYPE);
    userInfo.id =  sp.getInt(SP_ID);
    userInfo.idNO = sp.getString(SP_IDNO);
    userInfo.phone =  sp.getString(SP_PHONE);
    userInfo.isAuth =  sp.getString(SP_ISAUTH);
    userInfo.token = sp.getString(SP_TOKEN);
    userInfo.headImgUrl =  sp.getString(SP_HEADIMGURL);
    userInfo.companyId = sp.getInt(SP_COMPANYID);
    userInfo.workKey =  sp.getString(SP_WORKKEY);
    userInfo.companyName = sp.getString(SP_COMPANYNAME);
    userInfo.idHandleImgUrl = sp.getString(SP_IDHANDLEIMGURL);
    return userInfo;
  }

  static Future<NoticeInfo> getNoticeInfo() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    bool isLogin = sp.getBool(SP_IS_LOGIN);
    if (isLogin == null || !isLogin) {
      return null;
    }
    NoticeInfo noticeInfo = new NoticeInfo();
    noticeInfo.noticeTitle = sp.getString(SP_NOTICE_TITLE);
    noticeInfo.content = sp.getString(SP_NOTICE_CONTENT);
    return noticeInfo;
  }

  // 是否登录
  static Future<bool> isLogin() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    bool b = sp.getBool(SP_IS_LOGIN);
    return b != null && b;
  }

  // 获取accesstoken
  static Future<String> getAccessToken() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.getString(SP_AC_TOKEN);
  }

  // 获取accesstoken
  static Future<String> getUserId() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.getString(SP_USER_ID);
  }

  static clearLoginInfo() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    await sp.setString(SP_AC_TOKEN, "");
    await sp.setBool(SP_IS_LOGIN, false);
  }

  static savePararInfo(String name, String value) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    await sp.setString(name.toUpperCase(), value);
  }

  static Future<String> getPararInfo(String name) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.getString(name.toUpperCase());
  }
}
