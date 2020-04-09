import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:visitor/com/goldccm/visitor/db/FriendInfo.dart';
import 'package:visitor/com/goldccm/visitor/util/DataUtils.dart';
import 'package:visitor/com/goldccm/visitor/view/Chat/Message/frienddetail.dart';

/*
 * 好友搜索
 * Author:ody997
 * Email:hwk@growingpine.com
 * 2019/10/16
 */
class FriendSearch extends StatefulWidget {
  final userList;
  FriendSearch({Key key, this.userList}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return FriendSearchState();
  }
}

class FriendSearchState extends State<FriendSearch> {
  List<FriendInfo> _userLists = new List<FriendInfo>();
  List<FriendInfo> _selectUserLists = new List<FriendInfo>();
  TextEditingController textController = new TextEditingController();
  String _imageUrl;

  @override
  void dispose() {
    super.dispose();
  }
  @override
  void initState() {
    super.initState();
    _userLists = widget.userList;
    init();
  }
  init() async {
    _imageUrl = await DataUtils.getPararInfo("imageServerUrl");
  }
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: Row(
          children: <Widget>[
            Expanded(
              flex: 1,
              child:IconButton(
                  icon: Image(
                    image: AssetImage("assets/images/login_back.png"),
                    width: 20,
                    height: 20,
                    fit: BoxFit.fill,
                    color: Color(0xFF373737),),
                  onPressed: () {
                    setState(() {
                      FocusScope.of(context).requestFocus(FocusNode());
                      Navigator.pop(context);
                    });
                  }),
            ),
            Expanded(
              flex: 9,
              child: Container(
                height:40,
                alignment: Alignment.center,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child:  TextField(
                        decoration: new InputDecoration(
                          hintText: '搜索',
                          hintStyle: TextStyle(fontSize:16),
                          contentPadding: const EdgeInsets.only(bottom: 5),
                          border: InputBorder.none,),
                        onChanged: onSearchTextChanged,
                        controller: textController, style: TextStyle(height: 1,fontSize: 16),
                      ),
                    ),
                  ],
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color:Color(0xFFF6F6F6),
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Color(0xFFFFFFFF),
        elevation: 1,
        brightness: Brightness.light,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: <Widget>[
          Expanded(child: _buildInfo()),
        ],
      ),
    );
  }
  Widget _buildInfo() {
    return ListView.separated(
        itemCount:  _selectUserLists.length != null ?  _selectUserLists.length : 0,
        separatorBuilder: (context,index){
          return Container(
            child: Divider(
              height: 0,
            ),
          );
        },
        itemBuilder: (BuildContext context, int index) {
          return Container(
            color: Colors.white,
            child: ListTile(
              title: Text( _selectUserLists[index].name,textScaleFactor: 1.0,),
              leading:  _selectUserLists[index].virtualImageUrl!=null?CircleAvatar(backgroundImage:NetworkImage(_imageUrl+ _selectUserLists[index].virtualImageUrl),):CircleAvatar(backgroundImage: AssetImage("assets/images/visitor_icon_head.png"),),
              onTap: (){
                Navigator.push(context, CupertinoPageRoute(builder: (context)=>FriendDetailPage(user: _selectUserLists[index],)));
              },
            ),
          );
        });
  }

  void onSearchTextChanged(String value) {
    List<FriendInfo> _lists = new List<FriendInfo>();
    if (value == "") {
      textController.text = "";
    } else {
      for(var user in _userLists){
        if(user.name.contains(textController.text)){
          _lists.add(user);
        }
      }
    }
    setState(() {
      _selectUserLists=_lists;
    });
  }
}
