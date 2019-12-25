/*
 * 功能列表
 */
class FunctionLists{
  String iconImage;
  String iconTitle;
  String iconType;
  String iconName;
  bool iconShow;
  FunctionLists({this.iconImage,this.iconTitle,this.iconType,this.iconName,this.iconShow});

  FunctionLists.fromJson(Map json){
    this.iconTitle=json['title'];
    this.iconImage=json['image'];
    this.iconType=json['type'];
    this.iconName=json['name'];
  }
}