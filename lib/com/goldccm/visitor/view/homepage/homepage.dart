import 'dart:convert';
import 'dart:core';
import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:visitor/com/goldccm/visitor/view/homepage/MoreFunction.dart';
import 'package:visitor/com/goldccm/visitor/view/homepage/NewsView.dart';
import 'package:visitor/com/goldccm/visitor/view/homepage/notice.dart';
import 'package:visitor/com/goldccm/visitor/view/login/Login.dart';
import 'package:visitor/com/goldccm/visitor/view/shareroom/RoomList.dart';
import 'package:visitor/com/goldccm/visitor/view/visitor/fastInviteReq.dart';
import 'package:visitor/com/goldccm/visitor/view/visitor/fastvisitreq.dart';
import 'package:visitor/com/goldccm/visitor/view/visitor/visithistory.dart';
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
  List<FunctionLists> _baseLists = [
    FunctionLists(
        iconImage: 'assets/icons/more_function.png',
        iconTitle: '全部',
        iconType: '_more',
        iconName: '全部')
  ];
  List<FunctionLists> _lists = [];
  List<FunctionLists> _flists = [
    FunctionLists(
        iconImage: 'assets/icons/visitor_person_card.png',
        iconTitle: '门禁卡',
        iconType: '_mineCard',
        iconName: '门禁卡',
        iconShow: false),
    FunctionLists(
        iconImage: 'assets/icons/visit_invite.png',
        iconTitle: '快捷邀约',
        iconType: '_inviteReq',
        iconName: '快捷邀约',
        iconShow: true),
    FunctionLists(
        iconImage: 'assets/icons/visit_fastvisit.png',
        iconTitle: '快捷访问',
        iconType: '_visitReq',
        iconName: '快捷访问',
        iconShow: true),
    FunctionLists(
        iconImage: 'assets/icons/visit_qrcode.png',
        iconTitle: '访问二维码',
        iconType: '_visitorCard',
        iconName: '访问码',
        iconShow: true),
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
    print(RouterUtil.apiServerUrl);
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

  init() async {
    await PermissionHandlerUtil().initPermission();
    PermissionHandlerUtil().askStoragePermission();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    UserInfo user = await LocalStorage.load("userInfo");
    getImageServerUrl();
    getBanner();
    getNoticeInfo();
    getPrivilege(user);
    getNewsInfoList();
    setState(() {
      swiperLoop = true;
    });
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
          backgroundColor: Theme.of(context).backgroundColor,
          body: new Stack(
            children: <Widget>[
              new CustomScrollView(controller: _scrollController, slivers: <
                  Widget>[
                SliverAppBar(
                  title: Text("首页",
                      textAlign: TextAlign.center,
                      style: new TextStyle(fontSize: 18.0, color: Colors.white),
                      textScaleFactor: 1.0),
                  expandedHeight: 200.0,
                  flexibleSpace: FlexibleSpaceBar(
                    background: _buildBannerImage(),
                  ),
                  backgroundColor: Theme.of(context).appBarTheme.color,
                  centerTitle: true,
                  leading: null,
                  automaticallyImplyLeading: false,
                  actions: <Widget>[
                    noticeSize > 0
                        ? Badge(
                            child: new IconButton(
                                icon: Image.asset(
                                  "assets/images/visitor_icon_message.png",
                                  height: 25,
                                ),
                                onPressed: () {
                                  if (userProvider.info.orgId != null ||
                                      userProvider.info.companyId != null) {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                NoticePage()));
                                  } else {
                                    ToastUtil.showShortClearToast(
                                        "公告暂时只针对非访客开放");
                                  }
                                }),
                            badgeContent: Text(
                              '',
                              style: TextStyle(color: Colors.white),
                            ),
                            position: BadgePosition(top: 0, right: 5),
                          )
                        : new IconButton(
                            icon: Image.asset(
                              "assets/images/visitor_icon_message.png",
                              height: 25,
                            ),
                            onPressed: () {
                              if (userProvider.info.orgId != null ||
                                  userProvider.info.companyId != null) {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => NoticePage()));
                              } else {
                                ToastUtil.showShortClearToast("公告暂时只针对非访客开放");
                              }
                            }),
                  ],
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(0, 40, 0, 20),
                  sliver: new SliverGrid(
                    //Grid
                    gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                    ),
                    delegate: new SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        return _buildIconTab(_lists[index].iconImage,
                            _lists[index].iconName, _lists[index].iconType);
                      },
                      childCount: _lists.length,
                    ),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.only(left: 16.0),
                  sliver: new SliverToBoxAdapter(
                    child: new Text('新闻公告',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 2),
                        textScaleFactor: 1.0),
                  ),
                ),
                new SliverFixedExtentList(
                  itemExtent: 140,
                  delegate: new SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      //创建列表项
                      if (index == newsInfoList.length) {
                        return _buildProgressMoreIndicator();
                      } else {
                        return buildJobItem(context, index);
                      }
                    },
                    childCount: newsInfoList.length,
                  ),
                ),
              ]),
              Positioned(
                top: top,
                width: MediaQuery.of(context).size.width,
                height: 44,
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  child: RaisedButton(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    onPressed: () => print('message press'),
                    child: _buildSwiperNotice(userProvider),
                  ),
                ),
              ),
              Positioned(
                top: top + 12,
                left: 30,
                height: 21,
                width: 21,
                child: Container(
                    child: Image.asset("assets/icons/notice_message.png")),
              ),
              Positioned(
                top: top + 17,
                right: 35,
                height: 10,
                child: Container(
                  child: Image.asset("assets/icons/gengduo@2x.png"),
                ),
              ),
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
            new MaterialPageRoute(
                builder: (context) => new NewsWebPage(
                    news_url: newsinfo.newsUrl, title: newsinfo.newsName)));
      },
      child: new NewsView(newsinfo, imageServerUrl),
    );
  }
  //头图
  Widget _buildBannerImage() {
    return Container(
      height: 200.0,
      child: Swiper(
        scrollDirection: Axis.horizontal, // 横向
        itemCount: imageList.length, // 数量
        autoplay: false, // 自动翻页
        loop: swiperLoop,
        itemBuilder: _buildItemImage, // 构建
        controller: _swiperController,
        autoplayDelay: 6000,
        onTap: (index) {
          print('点击了第${index}');
        }, // 点击事件 onTap
        pagination: SwiperPagination(
            // 分页指示器
            alignment: Alignment.bottomCenter, // 位置 Alignment.bottomCenter 底部中间
            margin: const EdgeInsets.fromLTRB(0, 0, 0, 5), // 距离调整
            builder: DotSwiperPaginationBuilder(
                // 指示器构建
                space: 5, // 点之间的间隔
                size: 10, // 没选中时的
                activeSize: 12, // 选中时的大小
                color: Colors.black54, // 没选中时的颜色
                activeColor: Colors.white)), // 选中时的颜色
        //control: new SwiperControl(color: Colors.pink), // 页面控制器 左右翻页按钮
        scale: 1, // 两张图片之间的间隔
      ),
    );
  }
  //公告提醒
  Widget _buildSwiperNotice(var userProvider) {
    return Container(
      height: 40.0,
      padding: EdgeInsets.only(left: 25.0, top: 12.0),
      child: Swiper(
        loop: swiperLoop,
        controller: _swipernoticeController,
        scrollDirection: Axis.vertical, // 横向
        itemCount:
            noticeContentList.length <= 5 ? noticeContentList.length : 5, // 数量
        autoplay: false, // 自动翻页
        autoplayDelay: 5000,
        itemBuilder: _buildNoticeContent, // 构建
        onTap: (index) {
          if (userProvider.orgId != null || userProvider.companyId != null) {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => NoticePage()));
          } else {
            ToastUtil.showShortClearToast("公告暂未开放");
          }
        }, // 点击事件 onTap
        scale: 1, // 两张图片之间的间隔
      ),
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
                  width: 49,
                  height: 49,
                )),
            new Padding(
              padding: EdgeInsets.only(top: 4.0),
              child: new Text(
                text,
                textScaleFactor: 1.0,
                style: new TextStyle(fontSize: 12),
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
    return new Text(
      noticeContentList[index],
      textScaleFactor: 1.0,
      style: new TextStyle(
          fontSize: 14.0, color: Colors.black, fontWeight: FontWeight.w500),
    );
  }

  getBanner() async {
    var response =
        await Http.instance.get(Constant.getBannerUrl, debugMode: true);
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
        String noticeContent = notice.content;
        if (noticeContent.length >= 15) {
          noticeContent = noticeContent.substring(0, 15);
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
    this.newsCurrentPage++;
    String url = Constant.getNewsListUrl + newsCurrentPage.toString() + "/5";
    var response = await Http.instance.get(url,
        queryParameters: {"pageNum": newsCurrentPage, "pageSize": "5"});
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
            //取得4个中断
            if (_lists.length == 4) {
              break;
            }
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
          new MaterialPageRoute(builder: (BuildContext context) {
        return new Qrcode(qrCodecontent: qrMsg);
      }));
    } else {
      ToastUtil.showShortToast('请先进行实名认证，认证后开启该功能');
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
              context, MaterialPageRoute(builder: (context) => Login()));
        }
      }
    }
  }

  _requestVisitor() async {
    bool isAuth = await checkAuth();
    if (isAuth) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => FastVisitReq()));
    } else {
      ToastUtil.showShortClearToast("请先实名认证");
    }
  }

  _visitorCard() async {
    bool isAuth = await checkAuth();
    UserInfo userInfo = await LocalStorage.load("userInfo");
    if (isAuth) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => VisitHistory(
                    userInfo: userInfo,
                  )));
    } else {
      ToastUtil.showShortClearToast("请先实名认证");
    }
  }

  _meetingRoom() async {
    bool isAuth = await checkAuth();
    if (isAuth) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => RoomList(
                    type: 0,
                  )));
    } else {
      ToastUtil.showShortClearToast("请先实名认证");
    }
  }

  _more() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => MoreFunction()));
  }

  _inviteRequest() async {
    bool isAuth = await checkAuth();
    if (isAuth) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => FastInviteReq()));
    } else {
      ToastUtil.showShortClearToast("请先实名认证");
    }
  }
}
