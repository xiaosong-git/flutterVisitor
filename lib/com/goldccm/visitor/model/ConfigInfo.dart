import 'package:meta/meta.dart';
import 'dart:convert';

class ConfigInfo{

   String typeId;
   String content;

  ConfigInfo({
     this.typeId,
     this.content,
});

   ConfigInfo.fromJson(Map json){
     this.typeId=json['typeId'];
     this.content=json['content'];
   }
}