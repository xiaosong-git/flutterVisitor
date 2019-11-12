import 'package:meta/meta.dart';
import 'dart:convert';
/*
 * 新闻信息
 */
class NewsInfo{
   num id;
   String newsDate;//日期
   String newsName;//标题
   String newsDetail ;//简单描述
   String newsImageUrl;//图片
   String newsUrl;//跳转URL
   String newsStatus;//normarl:正常  disable:禁止

  NewsInfo({
     @required this.id,
     this.newsDate,
     this.newsName,
     this.newsDetail,
     this.newsImageUrl,
     this.newsUrl,
     this.newsStatus,
});

  NewsInfo.fromJson(Map json){
    this.id=json['id'];
    this.newsDate=json['newsDate'];
    this.newsName=json['newsName'];
    this.newsDetail=json['newsDetail'];
    this.newsImageUrl=json['newsImageUrl'];
    this.newsUrl=json['newsUrl'];
    this.newsStatus=json['newsStatus'];
  }

   static List<NewsInfo> getJsonFromDataList(var content){
     List<NewsInfo> _newsList =[];
     var mapData = content['rows'];
     mapData.forEach((obj){
       NewsInfo newsInfo = new NewsInfo(
         id:obj['id'],
         newsDate:obj['newsDate'],
         newsName:obj['newsName'],
         newsDetail:obj['newsDetail'],
         newsImageUrl:obj['newsImageUrl'],
         newsUrl:obj['newsUrl'],
         newsStatus:obj['newsStatus'],
       );
       _newsList.add(newsInfo);
     });
     return _newsList;
   }

}