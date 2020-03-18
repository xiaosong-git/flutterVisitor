/*
 * 接口URL地址全部存在放这
 */
class Constant {
  //生产环境
    static final String imageServerApiUrl = "http://47.98.205.206:8081/goldccm-imgServer/goldccm/image/gainData";
    static final String serverUrl = "http://47.96.71.163:8082/visitor/";
    static final String webSocketServerUrl ="ws://47.96.71.163:8082/visitor/";
    static final String imageServerUrl = "http://47.98.205.206/imgserver/";
  // 测试环境
//  static final String serverUrl = "http://121.36.45.232:8082/visitor/";
//  static final String webSocketServerUrl = "ws://121.36.45.232:8082/visitor/";
//  static final String imageServerApiUrl = "http://121.36.45.232:8081/goldccm-imgServer/goldccm/image/gainData";
//    static final String imageServerUrl = "http://121.36.45.232:8098/imgserver/";

  //////////////////////////////////////////////

  static final String userUrl = "user/";
  static final String codeUrl = "code/";
  static final String userFriendUrl = "userFriend/";
  static final String visitorRecodeUrl = "visitorRecord/";
  static final String orgUrl = "org/";
  static final String companyUrl = "company/";
  static final String noticeUrl = "notice/";
  static final String paramUrl = "param/";
  static final String attendanceUrl = "checkInWork/";
  static final String appVersionUrl = "appVersion/";
  static final String companyUserUrl = "companyUser/";
  static final String newsUrl = "news/";
  static final int connectTimeout = 3000;
  static final int receiveTimeout = 3000;
  static final double normalFontSize = 16.0;
  static final String USERAGREEMENTAPIURL = "http://xiaosong6.idverify.cn:8082/xieyi.html";

  /*
   * 个人接口 user
   * login 登录
   * register 注册
   * sendCode 发送验证码
   * isVerify 实名状态
   * verify 实名
   * forget/sysPwd 找回密码'
   * update/sysPwd 更新密码
   * nick 修改昵称头像
   * getUser 获取用户信息
   * setGesturePwd 设置手势密码
   * updateGesturePwd 更新手势密码
   * updatePhone 修改账号
   */
  static final String loginUrl = userUrl + "login";
  static final String registerUrl = userUrl + "register";
  static final String sendCodeUrl = codeUrl + "sendCode";
  static final String isVerifyUrl = userUrl + "isVerify";
  static final String verifyUrl = userUrl + "verify";
  static final String findPwdUrl = userUrl + "forget/sysPwd";
  static final String updatePwdUrl = userUrl + "update/sysPwd";
  static final String updateNickAndHeadUrl = userUrl + "nick";
  static final String getUserInfoUrl = userUrl + "getUser";
  static final String setGesturePwdUrl = userUrl + "setGesturePwd";
  static final String updateGesturePwdUrl = userUrl + "updateGesturePwd";
  static final String updatePhoneUrl = userUrl + "updatePhone";

  /*
   * 系统接口
   * list 公告列表
   * param 根据参数名获取参数值
   * banner 首页头图
   * updateAndroid/{channel}/{versionCode} 检测应用版本 channel 版本号 versionCode
   */
  static final String getNoticeListUrl = noticeUrl + "list";
  static final String getParamUrl = paramUrl;

  static final String getBannerUrl = "banner/";
  static final String checkUpdateUrl = appVersionUrl +
      "updateAndroid/{channel}/{versionCode}";
  /*
   * 打卡接口
   * save/group 保存打卡规则
   * gain/one 查看打卡
   * save/work 打卡
   * flow/create 提交流程
   * flow/check 查看流程
   * flow/myApprove 我审批的流程
   * flow/approveDetail 根据id查看流程
   * flow/approve 根据id批准流程
   */
   static final String attendanceSaveRuleUrl = attendanceUrl + "save/group";
   static final String attendanceCheckOneDayUrl = attendanceUrl + "gain/one";
   static final String attendanceRecordUrl = attendanceUrl + "save/work";
   static final String attendanceApplyUrl = "flow/create";
   static final String attendanceCheckApplyUrl = "flow/Check";
   static final String attendanceMyApproveUrl = "flow/myApprove";
   static final String attendanceApproveDetailUrl = "flow/approveDetail";
   static final String attendanceApproveUrl = "flow/approve";
  /*
   * 查询员工人员访客
   */
  static final String findVisitorIdUrl = userUrl + "findVisitorId";

  /*
   * "manage"用户查询员工
   */
  static final String fincCompanyIdUrl = userUrl +
      "findCompanyId/{pageNum}/{pageSize}";

  /*
   * 添加员工
   */
  static final String addUserUrl = userUrl + "addUser";

  /*
   * 删除员工
   */
  static final String deleteUserUrl = userUrl + "deleteUser";

  /*
   * 查询通讯录
   */
  static final String findUserFriendUrl = userFriendUrl + "findUserFriend";

  /*
   * 通过手机号查找用户
   */
  static final String findFriendByPhoneUrl = userFriendUrl + "findPhone";

  /*
   * 通过真实姓名查找用户
   */
  static final String findFriendByRealNameUrl = userFriendUrl + "findRealName";

  /*
   * 添加好友
   */
  static final String addUserFriendUrl = userFriendUrl + "addUserFriend";

  /*
   * 删除好友
   */
  static final String deleteUserFriendUrl = userFriendUrl + "deleteUserFriend";

  /*
   * 访问我的人
   */
  static final String visitMyPeopleUrl = visitorRecodeUrl +
      "visitMyPeople/{pageNum}/{pageSize}";

  /*
   * 正在申请访问的：1。通过 2.拒绝：添加拒绝理由
   */
  static final String adoptionAndRejectionUrl = visitorRecodeUrl +
      "adoptionAndRejection";

  /*
   * 查询我访问的人
   */
  static final String peopleIInterviewedUrl = visitorRecodeUrl +
      "peopleIInterviewed/{pageNum}/{pageSize}";

  /*
   * 查询我访问的人(通过状态)
   */
  static final String peopleIInterviewedRecordUrl = visitorRecodeUrl +
      "peopleIInterviewedRecord/{pageNum}/{pageSize}";

  /*
   * 查询和我同一公司员工的信息
   */
  static final String visitMyCompanyUrl = visitorRecodeUrl +
      "visitMyCompany/{pageNum}/{pageSize}";

  /*
   * 发起访问请求（包括地址，大厦，公司，真实姓名，访问时间，访问理由）
   */
  static final String visitRequestUrl = visitorRecodeUrl + "visitRequest";

  /*
   * 通过地址请求大厦名称
   */
  static final String requestMansionUrl = orgUrl + "requestMansion";

  /*
   * 通过大厦请求公司名称
   */
  static final String requestCompanyUrl = companyUrl + "requestCompany";

  /*
   * 首页新闻列表
   */
  static final String getNewsListUrl = newsUrl + "list/";

  /*
   * 查询是否有位确认记录
   */
  static final String findapplyingUrl = companyUserUrl + "findapplying";

  /*
   * 修改状态
   */
  static final String updateStatusUrl = companyUserUrl + "updateStatus";

  /*
   * 用户的公司（状态为确认）
   */
  static final String findApplySucUrl = companyUserUrl + "findApplySuc";

  /*
   * 切换默认公司
   */
  static final String updateCompanyIdAndRoleUrl = userUrl +
      "updateCompanyIdAndRole";

  /*
   * 获取访问历史记录
   */
  static final String visitHistoryUrl = visitorRecodeUrl + "inviteRecord";

  /*
   * 获取邀约历史记录
   */
  static final String inviteHistoryUrl = visitorRecodeUrl + "inviteRecord";

  /*
   * 获取好友历史记录
   */
  static final String friendHistoryUrl = visitorRecodeUrl + "inviteRecord";

  /*
   * 快速访问
   */
  static final String fastVisitUrl = visitorRecodeUrl + "visit";
}