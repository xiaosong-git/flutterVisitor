import 'package:meta/meta.dart';
import 'dart:convert';


class XzqhInfo{
   String id;
   String xzqhId;
   String xzqhDm;
   String xzqhMc;
   String sjXzqhDm;
   String status;
   String xzqhType;
   String charName;
   String pinyin;
   String pinyinJc;
   String xzqhMcJc;
   String xzqhRank;


  XzqhInfo({
    this.id,
    this.xzqhId,
    this.xzqhDm,
    this.xzqhMc,
    this.sjXzqhDm,
    this.status,
    this.xzqhType,
    this.charName,
    this.pinyin,
    this.pinyinJc,
    this.xzqhMcJc,
    this.xzqhRank
}
 );

   XzqhInfo.fromJson(Map json) {
     id = json['id'];
     xzqhId = json['xzqhId'];
     xzqhDm = json['xzqhDm'];
     xzqhMc = json['xzqhMc'];
     sjXzqhDm = json['sjXzqhDm'];
     status = json['status'];
     xzqhType = json['xzqhType'];
     charName = json['charName'];
     pinyin = json['pinyin'];
     pinyinJc = json['pinyinJc'];
     xzqhMcJc = json['xzqhMcJc'];
     xzqhRank = json['xzqhRank'];
   }


  }
