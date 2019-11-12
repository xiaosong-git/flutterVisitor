import 'dart:convert';
import 'package:meta/meta.dart';

/*
 * 头图信息
 */
class BannerInfo {
  int id;
  String title;
  String imgUrl;
  String hrefUrl;
  int status;
  num createTime;

  BannerInfo({
    this.id,
    this.title,
    this.imgUrl,
    this.hrefUrl,
    this.status,
    this.createTime,
  });

  BannerInfo.fromJson(Map json) {
    this.id = json['id'];
    this.title = json['title'];
    this.imgUrl = json['imgUrl'];
    this.hrefUrl = json['hrefUrl'];
    this.status = json['status'];
    this.createTime = json['createTime'];
  }

  static List<BannerInfo> fromJsonDataList(var json) {
    List<BannerInfo> _BannerInfoList = [];
    json.forEach((obj) {
      BannerInfo jo = new BannerInfo(
        id: obj['id'],
        title: obj['title'],
        imgUrl: obj['imgUrl'],
        hrefUrl: obj['hrefUrl'],
        status: obj['status'],
        createTime: obj['createTime'],
      );
      _BannerInfoList.add(jo);
    });
    return _BannerInfoList;
  }
}
