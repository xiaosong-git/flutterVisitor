/*
 * 功能列表
 */
class FunctionLists{
  String iconImage;
  String iconTitle;
  String iconType;
  FunctionLists({this.iconImage,this.iconTitle,this.iconType});
  FunctionLists.fromJson(Map json){
    this.iconTitle=json['title'];
    this.iconImage=json['image'];
    this.iconType=json['type'];
  }
}