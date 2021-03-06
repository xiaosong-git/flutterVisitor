import 'dart:convert';
import 'dart:io';
import 'package:badges/badges.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:visitor/com/goldccm/visitor/httpinterface/http.dart';
import 'package:visitor/com/goldccm/visitor/model/FunctionLists.dart';
import 'package:visitor/com/goldccm/visitor/model/UserInfo.dart';
import 'package:visitor/com/goldccm/visitor/model/UserModel.dart';
import 'package:visitor/com/goldccm/visitor/util/BadgeUtil.dart';
import 'package:visitor/com/goldccm/visitor/util/CommonUtil.dart';
import 'package:visitor/com/goldccm/visitor/util/Constant.dart';
import 'package:visitor/com/goldccm/visitor/util/DataUtils.dart';
import 'package:visitor/com/goldccm/visitor/util/LocalStorage.dart';
import 'package:visitor/com/goldccm/visitor/util/TimerUtil.dart';
import 'package:visitor/com/goldccm/visitor/util/ToastUtil.dart';
import 'package:visitor/com/goldccm/visitor/view/minepage/companypage.dart';
import 'package:visitor/com/goldccm/visitor/view/minepage/identifypage.dart';
import 'package:visitor/com/goldccm/visitor/view/minepage/securitypage.dart';
import 'package:visitor/com/goldccm/visitor/view/minepage/settingpage.dart';
import 'package:visitor/com/goldccm/visitor/view/shareroom/roomHistory.dart';
import 'package:visitor/com/goldccm/visitor/view/visitor/friendHistory.dart';
import 'package:visitor/com/goldccm/visitor/view/visitor/inviteHistory.dart';
import 'package:visitor/com/goldccm/visitor/view/visitor/inviteList.dart';
import 'package:visitor/com/goldccm/visitor/view/visitor/visitList.dart';
import 'package:visitor/com/goldccm/visitor/view/visitor/visithistory.dart';
//个人中心界面
//包含个人信息显示、历史消息记录、公司管理、安全管理、设置
class MinePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MinePageState();
  }
}
//_userInfo存放用户个人信息
UserInfo _userInfo=new UserInfo();

class MinePageState extends State<MinePage> {
  List<FunctionLists> _addlist=[FunctionLists(iconImage: 'assets/icons/实名认证V.png',iconTitle: '实名认证',iconType: '_verify'),FunctionLists(iconImage: 'assets/icons/会议室icon@2x.png',iconTitle:'会议室',iconType:'_meetingRoom'),FunctionLists(iconImage: 'assets/icons/公司管理@2x.png',iconTitle:'公司管理',iconType: '_companySetting' ),];
  List<FunctionLists> _baseList=[FunctionLists(iconImage:'assets/icons/安全管理@2x.png',iconTitle:'安全管理',iconType: '_securitySetting' ),FunctionLists(iconImage:'assets/icons/设置@2x.png',iconTitle: '设置',iconType:'_setting' )];
  List<FunctionLists> _list = [];
  BadgeUtil badge=BadgeUtil();
  int visitBadgeNumTotal=0;
  TimerUtil _timerUtil;
  ScrollController _minescrollController = new ScrollController();
  final double expandedHeight = 65.0;
  double get top {
    double res = expandedHeight;
    if ( _minescrollController.hasClients) {
      double offset =  _minescrollController.offset;
      res -= offset;
    }
    return res;
  }
  //初始化
  //获取个人信息和图片服务器地址
  @override
  void initState() {
    super.initState();
    init();
    getPrivilege();
    _minescrollController.addListener(() {
      var maxScroll = _minescrollController.position.maxScrollExtent;
      var pixel = _minescrollController.position.pixels;
      if(maxScroll==pixel){
        setState(() {});
      }else{
        setState(() {});
      }
    });
  }
  //数量提醒及用户信息获取
  init() async {
    UserInfo user=await LocalStorage.load("userInfo");
    _userInfo=user;
    //消息数量提醒
    _timerUtil=TimerUtil(mInterval: 5000);
    _timerUtil.setOnTimerTickCallback((int tick) async {
      int num=await BadgeUtil().requestConfirmCount();
      setState(() {
        visitBadgeNumTotal=num;
      });
    });
    _timerUtil.startTimer();
  }
  //个人中心角色权限获取
  Future getPrivilege() async {
    UserInfo user=await LocalStorage.load("userInfo");
      String url = Constant.serverUrl + "userAppRole/getRoleMenu";
      String threshold = await CommonUtil.calWorkKey(userInfo: user);
      var res = await Http().post(url, queryParameters: {
        "token": user.token,
        "userId": user.id,
        "factor": CommonUtil.getCurrentTime(),
        "threshold": threshold,
        "requestVer": CommonUtil.getAppVersion(),
      });
      //附加权限
      if (res != null) {
        if (res is String) {
          Map map = jsonDecode(res);
          if (map['data'] != null) {
              for (int j = 0; j < _addlist.length; j++) {
                for (int i = 0; i < map['data'].length; i++) {
                if (_addlist[j].iconTitle == map['data'][i]['menu_name']) {
                  _list.add(_addlist[j]);
                  break;
                }
                }
            }
          }
        }
      } else {

      }

      setState(() {
        //基础权限
        for (int i = 0; i < _baseList.length; i++) {
          _list.add(_baseList[i]);
        }
      });
  }
  @override
  void dispose() {
    _minescrollController.dispose();
    _timerUtil.cancel();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    var user = Provider.of<UserModel>(context);
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: Stack(
        children: <Widget>[
          CustomScrollView(
            controller:  _minescrollController,
            slivers: <Widget>[
              SliverAppBar(
                title: Text(
                  "我的",
                  textAlign: TextAlign.center,
                  style: new TextStyle(
                      fontSize: 18.0, color: Colors.white),textScaleFactor: 1.0
                ),
                expandedHeight: 100.0,
                backgroundColor: Theme.of(context).appBarTheme.color,
                automaticallyImplyLeading: false,
                centerTitle: true,
                leading: null,
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 150, 20, 0),
                sliver: new SliverGrid(
                  gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.0,
                  ),
                  delegate: new SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                      return _buildIconTab(_list[index].iconImage,_list[index].iconTitle,_list[index].iconType);
                    },
                    childCount: _list.length
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: top,
            height: 200,
            left: 15,
            right: 15,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              elevation: 20.0,
              child: Container(
                  height: 120,
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Container(
                            child: GestureDetector(
                              onTap: () {
                                if(_userInfo.headImgUrl != null||_userInfo.idHandleImgUrl!=null){
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => HeadImagePage())).then((value){
                                  });
                                }
                              },
                              child: CircleAvatar(
                                backgroundImage: _userInfo.headImgUrl != null?NetworkImage(
                                        Constant.imageServerUrl +
                                            (_userInfo.headImgUrl ),)
                                    : _userInfo.idHandleImgUrl!=null?NetworkImage(
                                  Constant.imageServerUrl +
                                      (_userInfo.idHandleImgUrl ),):AssetImage('assets/images/visitor_icon_account.png'),
                                radius: 100,
                              ),
                            ),
                            width: 60.0,
                            margin: EdgeInsets.all(20),
                            height: 60.0,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Consumer(
                                  builder:
                                      (context, UserModel userModel, widget) =>
                                          Text(
                                            userModel.info.realName != null
                                                ? userModel.info.realName
                                                : '暂未获取到数据',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 20.0,
                                            ),textScaleFactor: 1.0
                                          )),
                              Consumer(
                                builder:
                                    (context, UserModel userModel, widget) =>
                                        Text(
                                          userModel.info.companyName != null
                                              ? userModel.info.companyName
                                              : '暂未获取到数据',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 15.0,
                                          ),textScaleFactor: 1.0
                                        ),
                              )
                            ],
                          ),
                        ],
                      ),
                      Container(
                        child: Divider(
                          height: 5,
                          color: Colors.black12,
                        ),
                      ),
                      Container(
                        color: Colors.white,
                        child: Row(
                            children: <Widget>[
                              Material(
                                color: Colors.white,
                                child: InkWell(
                                  child: Container(
                                    width: 80,
                                    padding: EdgeInsets.all(15),
                                    child: Column(
                                      children: <Widget>[
                                        visitBadgeNumTotal!=0?Badge(
                                          child: Image.asset("assets/icons/访问.png",scale: 7.0,),
                                          badgeContent: Text(visitBadgeNumTotal.toString(),style: TextStyle(color: Colors.white),textScaleFactor: 1.0),
                                          badgeColor: Colors.red,
                                        ):Image.asset("assets/icons/访问.png",scale: 7.0,),
                                        Text('访问',textScaleFactor: 1.0),
                                      ],
                                    ),
                                  ),
                                  onTap: () {
                                    if(user.info.isAuth=="T") {
                                      Navigator.push(context, MaterialPageRoute(
                                          builder: (context) =>
                                              VisitList(
                                                userInfo: user.info,)));
                                    }else{
                                      ToastUtil.showShortClearToast("请先实名认证");
                                    }
                                  },
                                  splashColor: Colors.black12,
                                  borderRadius: BorderRadius.circular(18.0),
                                  radius: 30,
                                ),
                              ),
                              Material(
                                color: Colors.white,
                                child: InkWell(
                                  child: Container(
                                    width: 80,
                                    padding: EdgeInsets.all(15),
                                    child: Column(
                                      children: <Widget>[
                                        Image.asset("assets/icons/邀约.png",scale: 7.0,),
                                        Text('邀约',textScaleFactor: 1.0),
                                      ],
                                    ),
                                  ),
                                  onTap: () {
                                    if(user.info.isAuth=="T"){
                                      Navigator.push(context, MaterialPageRoute(builder: (context)=>InviteList(userInfo:user.info,)));
                                    }else{
                                      ToastUtil.showShortClearToast("请先实名认证");
                                    }
                                  },
                                  splashColor: Colors.black12,
                                  borderRadius: BorderRadius.circular(18.0),
                                  radius: 30,
                                ),
                              ),
                              Material(
                                color: Colors.white,
                                child: InkWell(
                                  child: Container(
                                    width: 80,
                                    padding: EdgeInsets.all(15),
                                    child: Column(
                                      children: <Widget>[
                                        Image.asset("assets/icons/好友.png",scale: 7.0,),
                                        Text('好友',textScaleFactor: 1.0),
                                      ],
                                    ),
                                  ),
                                  onTap: () {
                                    if(user.info.isAuth=="T") {
                                      Navigator.push(context, MaterialPageRoute(
                                          builder: (context) =>
                                              FriendHistory(
                                                userInfo: user.info,)));
                                    }else{
                                      ToastUtil.showShortClearToast("请先实名认证");
                                    }
                                  },
                                  splashColor: Colors.black12,
                                  borderRadius: BorderRadius.circular(18.0),
                                  radius: 30,
                                ),
                              ),
                            ],
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceAround),
                      ),
                    ],
                  )),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildIconTab(String url, String text,String method) {
    return InkWell(
          onTap: (){
            if(method=="_meetingRoom"){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>RoomHistory (userInfo: _userInfo,)));
            }else if(method=="_companySetting"){
              Navigator.push(context, MaterialPageRoute(builder: (context) => CompanyPage(userInfo: _userInfo,)));
            }else if(method=="_securitySetting"){
              Navigator.push(context, MaterialPageRoute(builder: (context) => SecurityPage(userInfo: _userInfo)));
            }else if(method=="_setting"){
              Navigator.push(context, MaterialPageRoute(builder: (context) => SettingPage()));
            }else if(method=="_verify"){
              if(_userInfo.isAuth=="T") {
                ToastUtil.showShortClearToast("您已完成实名认证");
              }else {
                Navigator.push(context, MaterialPageRoute(
                    builder: (context) => IdentifyPage(userInfo: _userInfo,)));
              }
            }
          },
          child: new Container(
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Padding(padding: EdgeInsets.only(top: 0.0),child: new Image.asset(url, width: 49, height: 49,)),
                new Padding(
                  padding: EdgeInsets.only(top: 4.0),
                  child: new Text(text, style: new TextStyle(fontSize: 14,fontWeight: FontWeight.bold),textScaleFactor: 1.0
                  ),
                ),
              ],
            ),
          ),
    );
  }
}

//头像修改
class HeadImagePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return HeadImagePageState();
  }
}

class HeadImagePageState extends State<HeadImagePage> {
  File _image;

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image;
    });
    _uploadImg();
  }

  Future getPhoto() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    setState(() {
      _image = image;
    });
    _uploadImg();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child:Scaffold(
          appBar: AppBar(
            title: Text('修改头像',textScaleFactor: 1.0),
            centerTitle: true,
            backgroundColor: Theme.of(context).appBarTheme.color,
            leading: IconButton(icon: Icon(Icons.arrow_back_ios), onPressed: (){Navigator.pop(context,_userInfo.headImgUrl);}),
          ),
          body: Column(
            children: <Widget>[
              Container(
                alignment: Alignment.center,
                height: 300,
                width: 300,
                child: ClipOval(
                  child: _image == null
                      ? Image.network(
                    Constant.imageServerUrl +
                        (_userInfo.headImgUrl != null
                            ? _userInfo.headImgUrl
                            : _userInfo.idHandleImgUrl),
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                  )
                      : Image.file(
                    _image,
                    fit: BoxFit.cover,
                    width: 200,
                    height: 200,
                  ),
                ),
              ),
              Center(
                  child:
                  Container(
                    color: Colors.white,
                    margin: EdgeInsets.all(5),
                    width: MediaQuery.of(context).size.width-40,
                    height: 50,
                    child: RaisedButton(child: Text('点击从相册中选取照片',textScaleFactor: 1.0,style: TextStyle(fontSize: 16.0),), onPressed: getImage,elevation: 5.0,color: Colors.white,shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),),
                  )
              ),
              Center(
                child:  Container(
                  color: Colors.white,
                  margin: EdgeInsets.all(5),
                  width: MediaQuery.of(context).size.width-40,
                  height: 50,
                  child:RaisedButton(child: Text('点击拍摄照片',textScaleFactor: 1.0,style: TextStyle(fontSize: 16.0),), onPressed: getPhoto,elevation: 5.0,color: Colors.white,shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0))),
                ),
              ),
            ],
          )),
      onWillPop: (){
        Navigator.pop(context,_userInfo.headImgUrl);
      },
    );
  }

  ///修改后的头像上传和个人信息内的头像地址的修改
  _uploadImg() async {
    String url = Constant.imageServerApiUrl;
    var name = _image.path.split("/");
    var filename = name[name.length - 1];
    FormData formData = FormData.from({
      "userId": _userInfo.id,
      "type": "4",
      "file": new UploadFileInfo(_image, filename),
    });
    var res = await Http().post(url, data: formData);
    Map map = jsonDecode(res);
    String nickurl = Constant.serverUrl+ Constant.updateNickAndHeadUrl;
    String threshold = await CommonUtil.calWorkKey();
    var nickres = await Http().post(nickurl, queryParameters: {
      "headImgUrl": map['data']['imageFileName'],
      "token": _userInfo.token,
      "userId": _userInfo.id,
      "factor": CommonUtil.getCurrentTime(),
      "threshold": threshold,
      "requestVer": CommonUtil.getAppVersion(),
    });
    setState(() {
      _userInfo.headImgUrl = map['data']['imageFileName'];
      DataUtils.updateUserInfo(_userInfo);
    });
    if(nickres is String){
      Map nickmap = jsonDecode(nickres);
      if(nickmap['verify']['desc']=="success"){
        ToastUtil.showShortClearToast(nickmap['verify']['desc']);
        Navigator.pop(context);
      }else{
        ToastUtil.showShortClearToast(nickmap['verify']['desc']);
      }
    }
  }

}
