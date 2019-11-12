import 'package:flutter/material.dart';

class MessageCompent extends StatelessWidget {
  String headImgUrl; //头像图片
  String realName; //真实姓名
  String latestTime; //最新消息发送时间
  String latestMsg; //最新消息
  String isSend; // 0-表示userid发送   1-表示FuserID发送
  num unreadCount; //未读信息条数
  String imageServerUrl; //图片服务器地址
  MessageCompent(
      {this.headImgUrl,
      this.realName,
      this.latestTime,
      this.latestMsg,
      this.isSend,
      this.unreadCount,
      this.imageServerUrl});
  @override
  Widget build(BuildContext context) {
    return new Padding(
      padding: EdgeInsets.only(left: 10.0,top: 10.0),
      child: Column(
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new Padding(
                padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                child: new Stack(
                  alignment: Alignment.topRight,
                  overflow: Overflow.visible,
                  children: <Widget>[
                    new Container(
                      width: 50.0,
                      height: 50.0,
                      child:  CircleAvatar(
                        backgroundImage: headImgUrl!=null
                            ? NetworkImage(imageServerUrl + headImgUrl)
                            : AssetImage(
                            'assets/images/visitor_icon_head.png'),
                        radius: 100,
                      ),
                    ),
                    Positioned(right: -5, top: -5, child: _buildBadge())
                  ],
                ),
              ),
              new Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  new Row(
                    children: <Widget>[
                      Container(
                        child: new Text(realName != null ? realName : "Unknown",
                            style: new TextStyle(
                                color: Colors.black,
                                fontSize: 18,),
                            textAlign: TextAlign.left,textScaleFactor: 1.0),
                        margin: EdgeInsets.only(top: 15.0, left: 15.0),
                      ),
                      new Expanded(
                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          new Padding(
                              padding: EdgeInsets.only(top: 15, right: 10),
                              child: new Text(
                                  DateTime.parse(latestTime).day ==
                                          DateTime.now().day
                                      ? latestTime.substring(11, 16)
                                      : latestTime.substring(5, 10),
                                  style: new TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,),
                                  textAlign: TextAlign.left,textScaleFactor: 1.0))
                        ],
                      ))
                    ],
                  ),
                  new Padding(
                      padding: EdgeInsets.only(top: 5.0, left: 15.0),
                      child: Text(
                          latestMsg.toString(),
                          softWrap: true,
                          style: new TextStyle(
                              color: Colors.grey,
                              fontSize: 12,),
                          textAlign: TextAlign.left,textScaleFactor: 1.0)),
                  new Padding(
                    padding: EdgeInsets.only(left: 15),
                    child: new Divider(),
                  )
                ],
              )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge() {
    if (null == unreadCount || unreadCount == 0) {
      return Container();
    }
    return Container(
      width: 20,
      padding: EdgeInsets.fromLTRB(0, 2, 0, 2),
      alignment: Alignment.center,
      decoration: BoxDecoration(
          color: Colors.red,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.all(Radius.circular(10))),
      child: Text(
        unreadCount.toString(),
        style: TextStyle(fontSize: 10, color: Colors.white),textScaleFactor: 1.0
      ),
    );
  }
}
