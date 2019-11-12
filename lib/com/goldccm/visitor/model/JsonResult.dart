import 'dart:convert';
/*
 *
 */
class JsonResult {
  String sign ;
  String desc ;
  var data;


  JsonResult.fromJson(var result){
   var jsonResult =json.decode(result);
    var verify = jsonResult['verify'];
    data = jsonResult['data'];
    sign = jsonResult['verify']['sign'];
    desc = jsonResult['verify']['desc'];
  }
  
}