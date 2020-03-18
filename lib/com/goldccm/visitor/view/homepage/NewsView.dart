import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:visitor/com/goldccm/visitor/model/NewsInfo.dart';
import 'package:visitor/com/goldccm/visitor/util/Constant.dart';
import 'package:visitor/com/goldccm/visitor/util/RouterUtil.dart';

class NewsView extends StatelessWidget {
  final NewsInfo newsInfo;
  final String imageServerUrl;
  NewsView(this.newsInfo, this.imageServerUrl);
  @override
  Widget build(BuildContext context) {
    return new Padding(
      padding: const EdgeInsets.only(
        top: 10,
        left: 14,
        right: 14,
      ),
      child: new Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          new Expanded(
            flex: 4,
            child: Container(
                height: ScreenUtil().setHeight(196),
//              padding: EdgeInsets.only(left: ScreenUtil().setWidth(32)),
                child:ClipRRect(
                  borderRadius: BorderRadius.circular(5.0),
                  child:  CachedNetworkImage(
                    imageUrl: RouterUtil.imageServerUrl + newsInfo.newsImageUrl,
                    placeholder: (context, url) => Container(
                      child: CircularProgressIndicator(
                        backgroundColor: Colors.black,
                      ),
                      width: 10,
                      height: 10, alignment: Alignment.center,),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                    fit: BoxFit.cover,
                  ),
                ),
            ),
          ),
          new Expanded(
              flex: 4,
              child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    new Container(
                      height: ScreenUtil().setHeight(142),
                        padding: EdgeInsets.only(left: ScreenUtil().setWidth(22)),
                        child:new RichText(
                              text: new TextSpan(
                                  text: newsInfo.newsName,
                                  style: new TextStyle(
                                    fontSize: ScreenUtil().setSp(32),
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  )),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              textScaleFactor: 1.0)
                          // child:new Text(newsInfo.newsName,overflow: TextOverflow.ellipsis,style: new TextStyle(fontSize: 15.0,color: Colors.black,fontFamily: '楷体_GB2312' )),
                    ),
                     Container(
                       padding: EdgeInsets.only(left: ScreenUtil().setWidth(280),top: ScreenUtil().setHeight(20)),
                       child: Text(
                           newsInfo.newsDate.substring(5),
                           style: new TextStyle(
                             fontSize: ScreenUtil().setSp(24),
                             color: Color(0xFFC5C5C5),
                           ),
                           textScaleFactor: 1.0,
                         overflow: TextOverflow.ellipsis,
                       ),
                     ),
                  ]
              )
          ),
        ],
      ),
    );
  }
}
