import 'dart:convert';
import 'package:badges/badges.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lpinyin/lpinyin.dart';
import 'package:provider/provider.dart';
import 'package:visitor/com/goldccm/visitor/db/FriendInfo.dart';
import 'package:visitor/com/goldccm/visitor/db/friendDao.dart';
import 'package:visitor/com/goldccm/visitor/httpinterface/http.dart';
import 'package:visitor/com/goldccm/visitor/model/BadgeModel.dart';
import 'package:visitor/com/goldccm/visitor/model/UserInfo.dart';
import 'package:visitor/com/goldccm/visitor/model/UserModel.dart';
import 'package:visitor/com/goldccm/visitor/util/CommonUtil.dart';
import 'package:visitor/com/goldccm/visitor/util/Constant.dart';
import 'package:visitor/com/goldccm/visitor/util/DataUtils.dart';
import 'package:visitor/com/goldccm/visitor/util/LocalStorage.dart';
import 'package:visitor/com/goldccm/visitor/util/RouterUtil.dart';
import 'package:visitor/com/goldccm/visitor/view/Chat/Book/addfriend.dart';
import 'package:visitor/com/goldccm/visitor/view/Chat/Book/contacts.dart';
import 'package:visitor/com/goldccm/visitor/view/Chat/Book/newfriend.dart';
import 'package:visitor/com/goldccm/visitor/view/Chat/Book/search.dart';
import 'package:visitor/com/goldccm/visitor/view/Chat/Message/frienddetail.dart';

//依据首字母排列的好友列表
class FirstNameList extends StatefulWidget{
  final List<FriendInfo> userLists;
  FirstNameList({Key key,this.userLists}):super(key:key);
  @override
  State<StatefulWidget> createState() {
    return FirstNameListState();
  }
}
class FirstNameListState extends State<FirstNameList>{
  UserModel _userModel;
  List<FriendInfo> _userLists = new List<FriendInfo>();
  bool initFlag = false;
  @override
  void initState() {
    super.initState();
    loadUserList();
  }
  Future refresh() async{
    loadUserList();
    return null;
  }
  @override
  Widget build(BuildContext context) {
    _userModel = Provider.of<UserModel>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('我的好友',textScaleFactor: 1.0,style: TextStyle(fontSize: ScreenUtil().setSp(36),color: Color(0xFF373737)),),
        backgroundColor: Color(0xFFFFFFFF),
        centerTitle: true,
        elevation: 1,
        brightness: Brightness.light,
        automaticallyImplyLeading: false,

        actions: <Widget>[
          IconButton(
            icon:Image(
              width: 40,
              height: 40,
              image: AssetImage("assets/images/Chat_Friend_Search.png"),
            ),
            onPressed: search,
          ),
          IconButton(
            icon:Image(
              width: 40,
              height: 40,
              image: AssetImage("assets/images/Chat_Friend_Add.png"),
            ),
            onPressed: callOption,
          ),
        ],
        leading: IconButton(
            icon: Image(
              image: AssetImage("assets/images/login_back.png"),
              width: ScreenUtil().setWidth(36),
              height: ScreenUtil().setHeight(36),
              color: Color(0xFF373737),),
            onPressed: () {
              setState(() {
                FocusScope.of(context).requestFocus(FocusNode());
                Navigator.pop(context);
              });
            }),
      ),
      body: RefreshIndicator(
        child: CustomScrollView(
          slivers: <Widget>[
            initFlag?_buildInfoWithoutData():_buildInfo(),
          ],
        ),
        onRefresh: refresh,
      )
    );
  }
  search(){
    Navigator.push(context,CupertinoPageRoute(builder: (context) => FriendSearch(userList: widget.userLists,)));
  }

  callOption() {
    Navigator.push(
        context,
        CupertinoPageRoute(
            builder: (context) => AddFriendPage(
              userInfo: _userModel.info,
            )));
  }
  loadUserList() async {
    FriendDao friendDao = FriendDao();
    _userLists.clear();
    UserInfo user = await LocalStorage.load("userInfo");
    String threshold = await CommonUtil.calWorkKey(userInfo: user);
    String url = Constant.findUserFriendUrl;
    var res = await Http().post(url,
        queryParameters: {
          "token": user.token,
          "userId": user.id,
          "factor": CommonUtil.getCurrentTime(),
          "threshold": threshold,
          "requestVer": await CommonUtil.getAppVersion(),
        },
        debugMode: true,
        userCall: false);
    if (res is String) {
      Map map = jsonDecode(res);
      if (map['verify']['sign'] == "success") {
        if (map['data'] != null) {
          initFlag = false;
          List userList = map['data'];
          if (userList.length == 0) {
            initFlag = true;
          }
          for (var userInfo in userList) {
            if (userInfo['realName'] != null &&
                userInfo['phone'] != null &&
                userInfo['realName'] != "" &&
                userInfo['phone'] != "") {
              FriendInfo _userInfo = FriendInfo.fromJson(userInfo, user.id);
              _userLists.add(_userInfo);
              bool isExist = await friendDao.isExist(_userInfo.userId);
              if (!isExist) {
                friendDao.insertFriendInfo(_userInfo);
              } else {
                friendDao.updateFriendInfo(_userInfo);
              }
            }
          }
          if (_userLists.length == 0) {
            initFlag = true;
          }
          _userLists.sort((a, b) => PinyinHelper.getFirstWordPinyin(a.name)
              .substring(0, 1)
              .compareTo(
              PinyinHelper.getFirstWordPinyin(b.name).substring(0, 1)));
          setState(() {

          });
        } else {
          initFlag = true;
        }
      }
    }
  }
  Widget _buildInfoWithoutData() {
    return SliverToBoxAdapter(
      child: Container(
          padding: EdgeInsets.only(top:60),
          child:Column(
            children: <Widget>[
              Image(
                height: 150,
                fit: BoxFit.fitHeight,
                image: AssetImage('assets/images/book_empty_background.png'),
              ),
              Text('暂无好友',textScaleFactor: 1,style: TextStyle(fontSize: 18,color: Color(0xFF373737)),)
            ],
          )
      ),
    );
  }
  Widget _buildInfo() {
    return SliverList(
      delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
        if (index == 0) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(left: 15),
                color: Color(0xFFFCFCFC),
                height: 20,
                child: Text(_userLists[index].firstZiMu,style: TextStyle(fontSize: 11)),
              ),
              Container(
                color: Colors.white,
                child: ListTile(
                  title: Text(_userLists[index].notice != null && _userLists[index].notice != "" ? _userLists[index].notice : _userLists[index].name),
                  leading: _userLists[index].virtualImageUrl != null && _userLists[index].virtualImageUrl != ""
                      ? CircleAvatar(
                    backgroundImage: NetworkImage(
                        RouterUtil.imageServerUrl + _userLists[index].virtualImageUrl),
                  )
                      : _userLists[index].realImageUrl != null && _userLists[index].realImageUrl != ""
                      ? CircleAvatar(
                    backgroundImage: NetworkImage(RouterUtil.imageServerUrl + _userLists[index].realImageUrl),
                  )
                      : CircleAvatar(
                    backgroundImage: AssetImage("assets/images/visitor_icon_head.png"),
                  ),
                  onTap: () {
                    Navigator.push(context,
                        CupertinoPageRoute(
                            builder: (context) => FriendDetailPage(user: _userLists[index])));
                  },
                ),
              )
            ],
          );
        } else if (_userLists[index].firstZiMu !=
            _userLists[index - 1].firstZiMu) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(left: 15),
                color: Color(0xFFFCFCFC),
                height: 20,
                child: Text(_userLists[index].firstZiMu,style: TextStyle(fontSize: 11),),
              ),
              Container(
                color: Color(0xFFFFFFFF),
                child: ListTile(
                  title: Text(_userLists[index].notice != null && _userLists[index].notice != "" ? _userLists[index].notice : _userLists[index].name),
                  leading: _userLists[index].virtualImageUrl != null && _userLists[index].virtualImageUrl != ""
                      ? CircleAvatar(
                    backgroundImage: NetworkImage(
                        RouterUtil.imageServerUrl + _userLists[index].virtualImageUrl),
                  )
                      : _userLists[index].realImageUrl != null && _userLists[index].realImageUrl != ""
                      ? CircleAvatar(
                    backgroundImage: NetworkImage(RouterUtil.imageServerUrl + _userLists[index].realImageUrl),
                  )
                      : CircleAvatar(
                    backgroundImage: AssetImage("assets/images/visitor_icon_head.png"),
                  ),
                  onTap: () {
                    Navigator.push(
                        context,
                        CupertinoPageRoute(
                            builder: (context) => FriendDetailPage(user: _userLists[index],)));
                  },
                ),
              )
            ],
          );
        } else {
          return Container(
            color: Colors.white,
            child: ListTile(
              title: Text(_userLists[index].notice != null && _userLists[index].notice != "" ? _userLists[index].notice : _userLists[index].name),
              leading: _userLists[index].virtualImageUrl != null && _userLists[index].virtualImageUrl != ""
                  ? CircleAvatar(
                backgroundImage: NetworkImage(
                    RouterUtil.imageServerUrl + _userLists[index].virtualImageUrl),
              )
                  : _userLists[index].realImageUrl != null && _userLists[index].realImageUrl != ""
                  ? CircleAvatar(
                backgroundImage: NetworkImage(RouterUtil.imageServerUrl + _userLists[index].realImageUrl),
              )
                  : CircleAvatar(
                backgroundImage: AssetImage("assets/images/visitor_icon_head.png"),
              ),
              onTap: () {
                Navigator.push(
                    context,
                    CupertinoPageRoute(
                        builder: (context) => FriendDetailPage(
                          user: _userLists[index],
                        )));
              },
            ),
          );
        }
      }, childCount: _userLists.length ?? 0,),
    );
  }
}