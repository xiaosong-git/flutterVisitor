import 'dart:async';
import 'package:flutter/material.dart';
import 'package:visitor/com/goldccm/visitor/model/FriendInfo.dart';
import 'package:visitor/com/goldccm/visitor/util/DataUtils.dart';
import 'package:visitor/com/goldccm/visitor/view/addresspage/addresspage.dart';
import 'package:visitor/com/goldccm/visitor/view/addresspage/frienddetail.dart';

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
        title: Text('搜索好友',style: TextStyle(fontSize: 17.0),textScaleFactor: 1.0),
        centerTitle: true,
        backgroundColor: Theme.of(context).appBarTheme.color,
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.pop(context);
            }),
      ),
      body: Column(
        children: <Widget>[
          Container(
            child: Container(
                height: 52.0,
                child: new Card(
                    child: new Container(
                      child: new Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(
                            width: 5.0,
                          ),
                          Icon(
                            Icons.search,
                            color: Colors.grey,
                          ),
                          Expanded(
                            child: Container(
                              alignment: Alignment.center,
                              child: TextField(
                                decoration: new InputDecoration(
                                    contentPadding: EdgeInsets.only(top: 0.0),
                                    hintText: '查找',
                                    border: InputBorder.none),
                                onChanged: onSearchTextChanged,
                                controller: textController,
                              ),
                            ),
                          ),
                          new IconButton(
                            icon: new Icon(Icons.cancel),
                            color: Colors.grey,
                            iconSize: 18.0,
                            onPressed: () {
                              onSearchTextChanged("");
                            },
                          ),
                        ],
                      ),
                    ))),
          ),
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
                Navigator.push(context, MaterialPageRoute(builder: (context)=>FriendDetailPage(user: _selectUserLists[index],)));
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
