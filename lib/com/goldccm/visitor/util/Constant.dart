class Constant {
  //actual
//    static final String imageServerApiUrl = "http://47.98.205.206:8081/goldccm-imgServer/goldccm/image/gainData";
//    static final String serverUrl = "http://47.96.71.163:8082/visitor/";
//    static final String webSocketServerUrl ="ws://47.96.71.163:8082/visitor/";
//    static final String imageServerUrl = "http://47.98.205.206/imgserver/";
//  test
  static final String serverUrl = "http://121.36.45.232:8082/visitor/";
  static final String webSocketServerUrl ="ws://121.36.45.232:8082/visitor/";
  static final String imageServerApiUrl = "http://47.98.205.206:8081/goldccm-imgServer/goldccm/image/gainData";
  static final String imageServerUrl = "http://47.98.205.206/imgserver/";
  //////////////////////////////////////////////
  static final String userUrl = "user/";
  static final String codeUrl = "code/";
  static final String userFriendUrl = "userFriend/";
  static final String visitorRecodeUrl = "visitorRecord/";
  static final String orgUrl = "org/";
  static final String companyUrl = "company/";
  static final String noticeUrl = "notice/";
  static final String paramUrl = "param/";
  static final String appVersionUrl = "appVersion/";
  static final String companyUserUrl = "companyUser/";
  static final String newsUrl = "news/";
  static final int connectTimeout = 3000;
  static final int receiveTimeout = 3000;
  static final double normalFontSize = 16.0;
  static final String USERAGREEMENTAPIURL = "http://xiaosong6.idverify.cn:8082/xieyi.html";

  /*
   * 登录
   */
  static final String loginUrl = userUrl + "login";

  /*
   * 注册
   */
  static final String registerUrl= userUrl + "register";

  /*
   * 发送验证码
   */
  static final String sendCodeUrl = codeUrl + "sendCode";

  /*
   * 验证用户是否已经实名认证
   */
  static final String  isVerifyUrl=userUrl+"isVerify";

  /*
   * 实名认证
   */
  static final String verifyUrl = userUrl + "verify";

  /*
   * 找回密码
   */
  static final String findPwdUrl = userUrl + "forget/sysPwd";

  /*
   * 修改密码
   */
  static final String updatePwdUrl = userUrl + "update/sysPwd";

  /*
   * 昵称头像修改
   */
  static final String  updateNickAndHeadUrl= userUrl + "nick";

  /*
   * 获取用户的信息
   */
  static final String  getUserInfoUrl= serverUrl + userUrl + "getUser";

  /*
   * 获取公告
   */
  static final String getNoticeListUrl = noticeUrl + "list";

  /*
   * 根据参数名获取参数信息
   */
  static final String getParamUrl = paramUrl ;

  /*
   * 获取首页banner
   */
  static final String getBannerUrl = "banner/";

  /*
   * 检查更新
   */
  static final String checkUpdateUrl = appVersionUrl + "updateAndroid/{channel}/{versionCode}";

  /*
   * 设置手势密码
   */
  static final String setGesturePwdUrl= userUrl + "setGesturePwd";

  /*
   * 更新手势密码
   */
  static final String updateGesturePwdUrl= userUrl + "updateGesturePwd";

  /*
   * 修改登录账号
   */
  static final String updatePhoneUrl = userUrl + "updatePhone";

  /*
   * 查询员工人员访客
   */
  static final String  findVisitorIdUrl = userUrl + "findVisitorId";

  /*
   * "manage"用户查询员工
   */
  static final String fincCompanyIdUrl =userUrl + "findCompanyId/{pageNum}/{pageSize}";

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
  static final String  findUserFriendUrl = userFriendUrl + "findUserFriend";

  /*
   * 通过手机号查找用户
   */
  static final String  findFriendByPhoneUrl = userFriendUrl + "findPhone";

  /*
   * 通过真实姓名查找用户
   */
  static final String findFriendByRealNameUrl= userFriendUrl + "findRealName";

  /*
   * 添加好友
   */
  static final String addUserFriendUrl= userFriendUrl + "addUserFriend";

  /*
   * 删除好友
   */
  static final String deleteUserFriendUrl = userFriendUrl + "deleteUserFriend";

  /*
   * 访问我的人
   */
  static final String visitMyPeopleUrl = visitorRecodeUrl + "visitMyPeople/{pageNum}/{pageSize}";

  /*
   * 正在申请访问的：1。通过 2.拒绝：添加拒绝理由
   */
  static final String adoptionAndRejectionUrl = visitorRecodeUrl + "adoptionAndRejection";

  /*
   * 查询我访问的人
   */
  static final String peopleIInterviewedUrl = visitorRecodeUrl + "peopleIInterviewed/{pageNum}/{pageSize}";

  /*
   * 查询我访问的人(通过状态)
   */
  static final String peopleIInterviewedRecordUrl = visitorRecodeUrl + "peopleIInterviewedRecord/{pageNum}/{pageSize}";

  /*
   * 查询和我同一公司员工的信息
   */
  static final String visitMyCompanyUrl = visitorRecodeUrl + "visitMyCompany/{pageNum}/{pageSize}";

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
   static final String updateCompanyIdAndRoleUrl = userUrl + "updateCompanyIdAndRole";
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
}
