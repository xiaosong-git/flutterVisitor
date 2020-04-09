import 'dart:convert';
import 'dart:core';
import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visitor/com/goldccm/visitor/component/Qrcode.dart';
import 'package:visitor/com/goldccm/visitor/httpinterface/http.dart';
import 'package:visitor/com/goldccm/visitor/model/FunctionLists.dart';
import 'package:visitor/com/goldccm/visitor/model/JsonResult.dart';
import 'package:visitor/com/goldccm/visitor/model/QrcodeMode.dart';
import 'package:visitor/com/goldccm/visitor/model/UserInfo.dart';
import 'package:visitor/com/goldccm/visitor/model/UserModel.dart';
import 'package:visitor/com/goldccm/visitor/util/CommonUtil.dart';
import 'package:visitor/com/goldccm/visitor/util/Constant.dart';
import 'package:visitor/com/goldccm/visitor/util/ContactsUtil.dart';
import 'package:visitor/com/goldccm/visitor/util/LocalStorage.dart';
import 'package:visitor/com/goldccm/visitor/util/MessageUtils.dart';
import 'package:visitor/com/goldccm/visitor/util/PremissionHandlerUtil.dart';
import 'package:visitor/com/goldccm/visitor/util/QrcodeHandler.dart';
import 'package:visitor/com/goldccm/visitor/util/RouterUtil.dart';
import 'package:visitor/com/goldccm/visitor/util/ToastUtil.dart';
import 'package:visitor/com/goldccm/visitor/util/DataUtils.dart';
import 'package:visitor/com/goldccm/visitor/model/BannerInfo.dart';
import 'package:visitor/com/goldccm/visitor/model/NoticeInfo.dart';
import 'package:visitor/com/goldccm/visitor/model/NewsInfo.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:visitor/com/goldccm/visitor/view/Add/Attendance/attendance.dart';
import 'package:visitor/com/goldccm/visitor/view/Add/Share/RoomList.dart';
import 'package:visitor/com/goldccm/visitor/view/Home/MoreFunction.dart';
import 'package:visitor/com/goldccm/visitor/view/Home/NewsView.dart';
import 'package:visitor/com/goldccm/visitor/view/Home/notice.dart';
import 'package:visitor/com/goldccm/visitor/view/login/Login.dart';
import 'package:visitor/com/goldccm/visitor/view/Add/Visit/fastInviteReq.dart';
import 'package:visitor/com/goldccm/visitor/view/Add/Visit/fastvisitreq.dart';
import 'package:visitor/com/goldccm/visitor/view/Chat/visithistory.dart';
import 'dart:async';
import 'NewsWebView.dart';

/*
 * 主页
 * create_time:2019/10/23
 */
class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new HomePageState();
  }
}

class HomePageState extends State<HomePage> {
  List<BannerInfo> bannerList = []; //头图
  List<NoticeInfo> noticeList = []; //公告列表
  List<NewsInfo> newsInfoList = []; //新闻列表
  List<String> imageList = [];
  List<String> noticeContentList = [];
  String imageServerUrl; //图片服务器地址
  List<FunctionLists> _baseLists = [];
  List<FunctionLists> _lists = [];
  List<FunctionLists> _flists = [
    FunctionLists(
        iconImage: 'assets/images/home_card.png',
        iconTitle: '门禁卡',
        iconType: '_mineCard',
        iconName: '门禁卡',
        iconShow: false),
    FunctionLists(
        iconImage: 'assets/images/home_invite.png',
        iconTitle: '快捷邀约',
        iconType: '_inviteReq',
        iconName: '快捷邀约',
        iconShow: true),
    FunctionLists(
        iconImage: 'assets/images/home_visit.png',
        iconTitle: '快捷访问',
        iconType: '_visitReq',
        iconName: '快捷访问',
        iconShow: true),
    FunctionLists(
        iconImage: 'assets/images/home_more.png',
        iconTitle: '访问二维码',
        iconType: '_visitorCard',
        iconName: '访问码',
        iconShow: true),
    FunctionLists(
        iconImage: 'assets/images/home_tearoom.png',
        iconTitle: '茶室',
        iconType: '_teaRoom',
        iconName: '茶室',
        iconShow: false),
    FunctionLists(
        iconImage: 'assets/images/home_meetingroom.png',
        iconTitle: '会议室',
        iconType: '_meetingRoom',
        iconName: '会议室',
        iconShow: false),
    FunctionLists(
        iconImage: 'assets/images/home_att.png',
        iconTitle: '打卡',
        iconType: '_attendance',
        iconName: '打卡',
        iconShow: false),
  ];
  SwiperController _swiperController;
  SwiperController _swipernoticeController;
  var newsCurrentPage = 0;
  bool swiperLoop = false;
  int noticeSize = 0;
  int totalSize = 0;
  ScrollController _scrollController = new ScrollController();
  String loadMoreText = "没有更多数据";
  TextStyle loadMoreTextStyle =
      new TextStyle(color: const Color(0xFF999999), fontSize: 14.0);
  TextStyle titleStyle =
      new TextStyle(color: const Color(0xFF757575), fontSize: 14.0);
  final double expandedHeight = 200.0;
  @override
  void initState() {
    super.initState();
    init();
    checkDevice();
    _swiperController = new SwiperController();
    _swiperController.startAutoplay();
    _swipernoticeController = new SwiperController();
    _swipernoticeController.startAutoplay();
    _scrollController.addListener(() {
      var maxScroll = _scrollController.position.maxScrollExtent;
      var pixel = _scrollController.position.pixels;
      if (maxScroll == pixel && newsInfoList.length < totalSize) {
        setState(() {
          loadMoreText = "正在加载中...";
          loadMoreTextStyle =
              new TextStyle(color: const Color(0xFF4483f6), fontSize: 14.0);
        });
        getNewsInfoList();
      } else {
        setState(() {
          loadMoreText = "没有更多数据";
          loadMoreTextStyle =
              new TextStyle(color: const Color(0xFF999999), fontSize: 14.0);
        });
      }
    });
  }
  //检测当前设备的合法性
  Future checkDevice() async {
    UserInfo userInfo = await LocalStorage.load("userInfo");
    if (userInfo == null || userInfo.id == null) {
      userInfo = await LocalStorage.load("userInfo");
    }
    String threshold = await CommonUtil.calWorkKey(userInfo: userInfo);
    var result = await Http().post(Constant.getUserInfoUrl,
        queryParameters: {
          "token": userInfo.token,
          "factor": CommonUtil.getCurrentTime(),
          "threshold": threshold,
          "requestVer": await CommonUtil.getAppVersion(),
          "userId": userInfo.id,
        },
        userCall: false);
    if (result != null) {
      if (!(result is String)) {
        if (result['verify']['sign'] == "tokenFail") {
          ToastUtil.showShortToast("您的账号已在另一台设备登录");
          MessageUtils.closeChannel();
          DataUtils.clearLoginInfo();
          Navigator.push(
              context, CupertinoPageRoute(builder: (context) => Login()));
        }
      }
    }
  }
  init() async {
    await PermissionHandlerUtil().initPermission();
    PermissionHandlerUtil().askStoragePermission();
    UserInfo user = await LocalStorage.load("userInfo");
    getImageServerUrl();
    getBanner();
    getNoticeInfo();
    getPrivilege(user);
    getNewsInfoList();
    ContactsUtil().updateContactsBackground();

//    setState(() {
//      swiperLoop = true;
//    });
  }

  @override
  void dispose() {
    _swiperController?.stopAutoplay();
    _swiperController?.dispose();
    _scrollController?.dispose();
    _swipernoticeController?.stopAutoplay();
    _swipernoticeController?.dispose();
    swiperLoop = false;
    super.dispose();
  }

  double get top {
    double res = expandedHeight;
    if (_scrollController.hasClients) {
      double offset = _scrollController.offset;
      res -= offset;
    }
    return res;
  }
  @override
  Widget build(BuildContext context) {
    var userProvider = Provider.of<UserModel>(context);
    return WillPopScope(
      child: Scaffold(
          backgroundColor:Color(0xFFFFFFFF),
          body: new Stack(
            children: <Widget>[
              new CustomScrollView(controller: _scrollController, slivers: <
                  Widget>[
                SliverAppBar(
//                  title: Text("首页",
//                      textAlign: TextAlign.center,
//                      style: new TextStyle(fontSize: 18.0, color: Colors.white),
//                      textScaleFactor: 1.0),
                  expandedHeight: ScreenUtil().setHeight(375),
                  flexibleSpace: FlexibleSpaceBar(
                    background: _buildBannerImage(),
                  ),
                  backgroundColor: Theme.of(context).appBarTheme.color,
                  centerTitle: true,
                  leading: null,
                  brightness: Brightness.dark,
                  automaticallyImplyLeading: false,
                ),
                SliverToBoxAdapter(
                  child: Container(
                    color: Color(0xFFFFFFFF),
                    padding: EdgeInsets.only(top:ScreenUtil().setHeight(24)),
                    height: ScreenUtil().setHeight(194),
                    child:Swiper(
                      scrollDirection: Axis.horizontal, // 横向
                      itemCount: imageList.length, // 数量
                      autoplay: false, // 自动翻页
                      loop: false,
                      itemBuilder: (BuildContext context,int index){
                        return GridView.count(
                          crossAxisCount: 5,
                          children: _getFunctionItem(index+1, 5),
                          padding: EdgeInsets.all(0),
                        );
                      },
//                      controller: _swiperController,
                      onTap: (index) {
                        print('点击了第${index}');
                      }, // 点击事件 onTap
                      pagination: SwiperPagination(
                        // 分页指示器
                          alignment: Alignment.bottomCenter, // 位置 Alignment.bottomCenter 底部中间
                          margin: const EdgeInsets.fromLTRB(0, 0, 0, 5), // 距离调整
                          builder: DotSwiperPaginationBuilder(
                            // 指示器构建
                              space: 3, // 点之间的间隔
                              size: 8, // 没选中时的
                              activeSize: 8, // 选中时的大小
                              color: Color(0xFFECF5FF), // 没选中时的颜色
                              activeColor: Color(0xFF177FFF),
                          )
                      ), // 选中时的颜色
                      //control: new SwiperControl(color: Colors.pink), // 页面控制器 左右翻页按钮
                      scale: 1, // 两张图片之间的间隔
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    color: Color(0xFFF9F9F9),
                    height: ScreenUtil().setHeight(16),
                  ),
                ),
                SliverToBoxAdapter(
                  child:  Container(
                    color: Color(0xFFFFFFFF),
                    height: ScreenUtil().setHeight(88),
                    child: _buildSwiperNotice(userProvider),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    color: Color(0xFFF9F9F9),
                    height: ScreenUtil().setHeight(16),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.only(left: ScreenUtil().setHeight(32),top: ScreenUtil().setHeight(32)),
                  sliver: new SliverToBoxAdapter(
                    child: Stack(
                      children: <Widget>[
                        Positioned(
                          child:   Text('新闻中心',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 2),
                              textScaleFactor: 1.0),
                        ),
//                        Positioned(
//                          right: ScreenUtil().setWidth(66),
//                          top: ScreenUtil().setHeight(10),
//                          child: InkWell(
//                            child: Text('更多',style: TextStyle(color: Color(0xFF737373),fontSize: ScreenUtil().setSp(28)),),
//                            onTap: (){
//
//                            },
//                          ),
//                        ),
                      ],
                    )
                  ),
                ),
                newsInfoList.length>0?SliverToBoxAdapter(
                  child: InkWell(
                    child:Container(
                      height: ScreenUtil().setHeight(358),
                      padding: EdgeInsets.only(left: ScreenUtil().setWidth(32)),
                      child:Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                              padding: EdgeInsets.only(top: ScreenUtil().setHeight(24),bottom: ScreenUtil().setHeight(16)),
                              child:ClipRRect(
                                borderRadius: BorderRadius.circular(5.0),
                                child: CachedNetworkImage(
                                  imageUrl: RouterUtil.imageServerUrl + newsInfoList[0].newsImageUrl,
                                  placeholder: (context, url) =>Container(
                                    child: CircularProgressIndicator(backgroundColor: Colors.black,),
                                    width: 10,
                                    height: 10,
                                    alignment: Alignment.center,
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Icon(Icons.error),
                                  fit: BoxFit.cover,
                                  width: ScreenUtil().setWidth(686),
                                  height: ScreenUtil().setHeight(234),
                                ),
                              ),
                          ),
                          Container(
                            child: RichText(
                                text: new TextSpan(
                                    text: newsInfoList[0].newsName,
                                    style: new TextStyle(
                                      fontSize: ScreenUtil().setSp(32),
                                      fontWeight: FontWeight.w600,
                                      color:Color(0xFF373737),)),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis, textScaleFactor: 1.0
                            ),
                          ),
                        ],
                      ),
                    ),
                    onTap: (){
                      Navigator.push(
                          context,
                          new CupertinoPageRoute(
                              builder: (context) => new NewsWebPage(
                                  news_url: newsInfoList[0].newsUrl, title: newsInfoList[0].newsName)));
                    },
                  )
                ):SliverToBoxAdapter(
                  child: Container(
                    height: ScreenUtil().setHeight(358),
                    padding: EdgeInsets.only(left: ScreenUtil().setWidth(32)),
                  ),
                ),
                new SliverFixedExtentList(
                  itemExtent: 130,
                  delegate: new SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                     if (index == newsInfoList.length-1) {
                        return _buildProgressMoreIndicator();
                      }else{
                        return buildJobItem(context, index+1);
                      }
                    },
                    childCount: newsInfoList.length-1,
                  ),
                ),
              ]),
            ],
          )),
    );
  }

  Widget _buildProgressMoreIndicator() {
    return new SliverPadding(
      padding: const EdgeInsets.all(15.0),
      sliver: new Center(
        child: new Text(loadMoreText,
            style: loadMoreTextStyle, textScaleFactor: 1.0),
      ),
    );
  }

  Widget buildJobItem(BuildContext context, int index) {
    NewsInfo newsinfo = newsInfoList[index];
    return new InkWell(
      onTap: () {
        Navigator.push(
            context,
            new CupertinoPageRoute(
                builder: (context) => new NewsWebPage(
                    news_url: newsinfo.newsUrl, title: newsinfo.newsName)));
      },
      child: new NewsView(newsinfo, imageServerUrl),
    );
  }
  List<Widget> _getFunctionItem(int index,int page){
    List<Widget> list = List();
    for(var i=0;i<_lists.length;i++){
      if((index-1)*page<=i&&i<index*page){
        list.add(
        _buildIconTab(_lists[i].iconImage,
        _lists[i].iconName, _lists[i].iconType)
        );
      }
    }
    return list;
  }
  //头图
  Widget _buildBannerImage() {
    return Container(
      height:ScreenUtil().setHeight(375),
      child: Swiper(
        scrollDirection: Axis.horizontal,
        itemCount: imageList.length<=7?imageList.length:7,
        autoplay: false,
        loop: swiperLoop,
        itemBuilder: _buildItemImage,
        controller: _swiperController,
        autoplayDelay: 8000,
        onTap: (index) {
          Navigator.push(
              context,
              new CupertinoPageRoute(
                  builder: (context) => new NewsWebPage(
                      news_url: bannerList[index].hrefUrl, title: bannerList[index].title)));
        },
        pagination: SwiperPagination(
            alignment: Alignment.bottomCenter,
            margin: const EdgeInsets.fromLTRB(0, 0, 0, 5),
            builder: DotSwiperPaginationBuilder(
                space: 3,
                size: 8,
                activeSize: 8,
                color: Colors.white12,
                activeColor: Colors.white)
        ),
        //control: new SwiperControl(color: Colors.pink), // 页面控制器 左右翻页按钮
        scale: 1, // 两张图片之间的间隔
      ),
    );
  }
  //公告提醒
  Widget _buildSwiperNotice(var userProvider) {
    return Container(
      height: ScreenUtil().setHeight(88),
      child: Stack(
        children: <Widget>[
          Positioned(
            top: ScreenUtil().setHeight(22),
            left: ScreenUtil().setWidth(32),
            child: Text('公告',style: TextStyle(color: Color(0xFF595959),fontSize: ScreenUtil().setSp(32),fontWeight: FontWeight.w600),),
          ),
//          Positioned(
//            top: ScreenUtil().setHeight(12),
//            left: ScreenUtil().setWidth(90),
//            child: Image(
//              image: AssetImage("assets/images/home_notice_new.png"),
//              width: ScreenUtil().setWidth(80),
//              height: ScreenUtil().setHeight(80),
//            ),
//          ),
          Positioned(
            left: ScreenUtil().setWidth(110),
//            top: ScreenUtil().setHeight(25),
            child: Container(
                  width: ScreenUtil().setWidth(604),
                  height: ScreenUtil().setHeight(88),
                  child: Swiper(
                    loop: swiperLoop,
                    controller: _swipernoticeController,
                    scrollDirection: Axis.vertical, // 横向
                    itemCount:
                    noticeContentList.length <= 7 ? noticeContentList.length : 7, // 数量
                    autoplay: false, // 自动翻页
                    autoplayDelay: 5000,
                    itemBuilder: _buildNoticeContent, // 构建
                    onTap: (index) {
                      Navigator.push(
                          context, CupertinoPageRoute(builder: (context) => NoticePage()));
                    },
                    scale: 1,
                  ),
                ),
          ),
        ],
      )
    );
  }

  //功能列表
  Widget _buildIconTab(String imageurl, String text, String iconType) {
    return new InkWell(
      onTap: () {
        if (iconType == '_mineCard') {
          _mineCard();
        } else if (iconType == '_visitReq') {
          _requestVisitor();
        } else if (iconType == '_visitorCard') {
          _visitorCard();
        } else if (iconType == '_more') {
          _more();
        } else if (iconType == "_meetingRoom") {
          _meetingRoom();
        } else if (iconType == "_inviteReq") {
          _inviteRequest();
        }else if (iconType == '_teaRoom') {
          _teaRoom();
        }else if(iconType == "_attendance"){
          _attendance();
        }
      },
      child: new Container(
        height: 140.0,
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            new Padding(
                padding: EdgeInsets.only(top: 0.0),
                child: new Image.asset(
              imageurl,
              width: ScreenUtil().setWidth(90),
              height: ScreenUtil().setWidth(90),
              fit: BoxFit.cover,
            )),
            new Padding(
              padding: EdgeInsets.only(top: 4.0),
              child: new Text(
                text,
                textScaleFactor: 1.0,
                style: new TextStyle(fontSize: ScreenUtil().setSp(24),color: Color(0xFF000000)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemImage(BuildContext context, int index) {
    return CachedNetworkImage(
      imageUrl: RouterUtil.imageServerUrl + imageList[index],
      placeholder: (context, url) =>
          Container(
                  child: CircularProgressIndicator(backgroundColor: Colors.black,),
                  width: 10,
                  height: 10,
                  alignment: Alignment.center,
                ),
      errorWidget: (context, url, error) =>
          Icon(Icons.error),
      fit: BoxFit.cover,
    );
  }

  Widget _buildNoticeContent(BuildContext context, int index) {
    return Row(
      children: <Widget>[
        index==1?Container(
          padding: EdgeInsets.only(top: ScreenUtil().setHeight(12)),
          child:  Image(
            image: AssetImage("assets/images/home_notice_new.png"),
            width: ScreenUtil().setWidth(80),
            fit: BoxFit.cover,
          ),
        ):Container(
          width: ScreenUtil().setWidth(20),
          padding: EdgeInsets.only(top: ScreenUtil().setHeight(12)),
        ),
        Text(
        noticeContentList[index],
          textScaleFactor: 1.0,
          style: new TextStyle(
          fontSize: ScreenUtil().setSp(28), color: Color(0xFF656565)),
        ),
      ],
    );
  }

  getBanner() async {
    UserInfo userInfo=await LocalStorage.load("userInfo");
    var response =
        await Http.instance.get(Constant.getBannerUrl, queryParameters:{"userId":userInfo.id},debugMode: true);
//    new Timer(Duration(milliseconds: 500),(){
    JsonResult responseResult = JsonResult.fromJson(response);
    if (responseResult.sign == 'success') {
      setState(() {
        bannerList = BannerInfo.fromJsonDataList(responseResult.data);
        bannerList.forEach((banner) {
          String imageUrl = banner.imgUrl;
          imageList.add(imageUrl);
        });
      });
    } else {
      ToastUtil.showShortToast('获取图片错误');
    }
//    );
  }

  getNoticeInfo() async {
    String url = Constant.getNoticeListUrl + "/1/10";
    var response = await Http.instance
        .get(url, queryParameters: {"pageNum": "1", "pageSize": "10"});
    if (!mounted) return;
    JsonResult responseResult = JsonResult.fromJson(response);
    if (responseResult.sign == 'success') {
      noticeList = NoticeInfo.getJsonFromDataList(responseResult.data);
      noticeList.forEach((notice) {
        String noticeContent = notice.noticeTitle;
        if (noticeContent.length >= 19) {
          noticeContent = noticeContent.substring(0, 19);
        }
        noticeContent += "...";
        noticeContentList.add(noticeContent);
      });
    } else {
      ToastUtil.showShortToast('获取消息列表错误');
    }
  }

  getImageServerUrl() async {
    String url = Constant.getParamUrl + "imageServerUrl";
    var response = await Http.instance.get(url,
        queryParameters: {"paramName": "imageServerUrl"}, debugMode: true);
    if (!mounted) return;
    JsonResult responseResult = JsonResult.fromJson(response);
    if (responseResult.sign == 'success') {
      imageServerUrl = responseResult.data;
      DataUtils.savePararInfo("imageServerUrl", imageServerUrl);
    } else {
      ToastUtil.showShortToast(responseResult.desc);
    }
  }

  Future _pullToRefresh() async {
    newsCurrentPage = 0;
    newsInfoList.clear();
    getNewsInfoList();
    return null;
  }

  getNewsInfoList() async {
    UserInfo userInfo =await LocalStorage.load("userInfo");
    this.newsCurrentPage++;
    String url = Constant.getNewsListUrl + newsCurrentPage.toString() + "/5";
    var response = await Http.instance.get(url,
        queryParameters: {
      "pageNum": newsCurrentPage,
          "pageSize": "5",
        "userId":userInfo.id});
    JsonResult responseResult = JsonResult.fromJson(response);
    if (responseResult.sign == 'success') {
      newsInfoList.addAll(NewsInfo.getJsonFromDataList(responseResult.data));
      totalSize = responseResult.data['total'];
    } else {
      ToastUtil.showShortToast('获取消息列表错误');
    }
  }

  //权限列表获取
  Future getPrivilege(UserInfo user) async {
    String url = "userAppRole/getRoleMenu";
    String threshold = await CommonUtil.calWorkKey(userInfo: user);
    //从服务器读取权限
    var res = await Http().post(url,
        queryParameters: {
          "token": user.token,
          "userId": user.id,
          "factor": CommonUtil.getCurrentTime(),
          "threshold": threshold,
          "requestVer": await CommonUtil.getAppVersion(),
        },
        userCall: false);
    if (res != null) {
      if (res is String) {
        Map map = jsonDecode(res);
        if (map['data'] != null) {
          //与本地权限匹配
          for (int j = 0; j < _flists.length; j++) {

            for (int i = 0; i < map['data'].length; i++) {
              //默认权限
              if (_flists[j].iconShow == true) {
                _lists.add(_flists[j]);
                break;
              }
              //附加权限
              if (_flists[j].iconTitle == map['data'][i]['menu_name']) {
                _lists.add(_flists[j]);
                break;
              }
            }
          }
        }
      }
    } else {}
    setState(() {
      //基础权限
      for (int i = 0; i < _baseLists.length; i++) {
        _lists.add(_baseLists[i]);
      }
    });
  }

  Future<bool> checkAuth() async {
    var _user = Provider.of<UserModel>(context);
    if (_user.info != null && _user.info.isAuth == 'T') {
      return true;
    } else {
      return false;
    }
  }

  _mineCard() async {
    bool isAuth = await checkAuth();
    if (isAuth) {
      UserInfo userInfo = await LocalStorage.load("userInfo");
      print("mineCard:" + userInfo.toString());
      QrcodeMode model =
          new QrcodeMode(userInfo: userInfo, totalPages: 1, bitMapType: 1);
      List<String> qrMsg = QrcodeHandler.buildQrcodeData(model);
      print('$qrMsg[0]');
      Navigator.push(context,
          new CupertinoPageRoute(builder: (BuildContext context) {
        return new Qrcode(qrCodecontent: qrMsg);
      }));
    } else {
      ToastUtil.showShortToast('请先进行实人认证，认证后开启该功能');
    }
  }

  outLogin() async {
    UserInfo userInfo = await LocalStorage.load("userInfo");
    String url = "app/quit";
    String threshold = await CommonUtil.calWorkKey(userInfo: userInfo);
    var res = await Http().post(url,
        queryParameters: {
          "token": userInfo.token,
          "userId": userInfo.id,
          "factor": CommonUtil.getCurrentTime(),
          "threshold": threshold,
          "requestVer": await CommonUtil.getAppVersion(),
        },
        userCall: false);
    if (res != null) {
      if (res is String) {
        Map map = jsonDecode(res);
        if (map['verify']['sign'] == "success") {
          SharedPreferences sp = await SharedPreferences.getInstance();
          sp.setBool("isLogin", false);
          Provider.of<UserModel>(context).init(UserInfo());
          MessageUtils.closeChannel();
          Navigator.push(
              context, CupertinoPageRoute(builder: (context) => Login()));
        }
      }
    }
  }

  _requestVisitor() async {
    bool isAuth = await checkAuth();
    if (isAuth) {
      Navigator.push(
          context, CupertinoPageRoute(builder: (context) => FastVisitReq()));
    } else {
      ToastUtil.showShortClearToast("请先实人认证");
    }
  }

  _visitorCard() async {
    bool isAuth = await checkAuth();
    UserInfo userInfo = await LocalStorage.load("userInfo");
    if (isAuth) {
      Navigator.push(
          context,
          CupertinoPageRoute(
              builder: (context) => VisitHistory(
                    userInfo: userInfo,
                  )));
    } else {
      ToastUtil.showShortClearToast("请先实人认证");
    }
  }

  _meetingRoom() async {
    bool isAuth = await checkAuth();
    if (isAuth) {
      Navigator.push(
          context,
          CupertinoPageRoute(
              builder: (context) => RoomList(
                    type: 0,
                  )));
    } else {
      ToastUtil.showShortClearToast("请先实人认证");
    }
  }

  _more() {
    Navigator.push(
        context, CupertinoPageRoute(builder: (context) => MoreFunction()));
  }

  _inviteRequest() async {
    bool isAuth = await checkAuth();
    if (isAuth) {
      Navigator.push(
          context, CupertinoPageRoute(builder: (context) => FastInviteReq()));
    } else {
      ToastUtil.showShortClearToast("请先实人认证");
    }
  }
  _teaRoom() async {
    UserInfo userInfo = await LocalStorage.load("userInfo");
    if (userInfo.isAuth == "T") {
      Navigator.push(
          context,
          CupertinoPageRoute(
              builder: (context) => RoomList(
                type: 1,
              )));
    } else {
      ToastUtil.showShortClearToast("请先实人认证");
    }
  }
  _attendance() async {
    UserInfo userInfo = await LocalStorage.load("userInfo");
    if (userInfo.isAuth == "T") {
      Navigator.push(
          context,
          CupertinoPageRoute(
              builder: (context) => AttendancePage(
              )));
    } else {
      ToastUtil.showShortClearToast("请先实人认证");
    }
  }
}
