import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:visitor/com/goldccm/visitor/meta/province.dart';
import 'package:visitor/com/goldccm/visitor/model/base_citys.dart';
import 'package:visitor/com/goldccm/visitor/model/point.dart';
import 'package:visitor/com/goldccm/visitor/model/result.dart';

//地址选择
//create_time:2020/1/25
class SelectAddressPage extends StatefulWidget{
  final Map<String,dynamic> provincesData;
  final Map<String,dynamic> citiesData;
  SelectAddressPage({Key key,this.provincesData,this.citiesData}):super(key:key);
  @override
  State<StatefulWidget> createState() {
    return SelectAddressPageState();
  }
}
// 界面状态
enum Status {
  Province,
  City,
  Area,
  Over,
}
class HistoryPageInfo {
  Status status;
  List<Point> itemList;

  HistoryPageInfo({this.status, this.itemList});
}

class SelectAddressPageState extends State<SelectAddressPage>{
  //省份数据
  List<Point> provinces;
  //城市数据
  CityTree cityTree;
  //当前页面状态
  Status pageStatus;
  //展示数据
  List<Point> itemList;
  //历史数据
  List<HistoryPageInfo> _history=[];
  //选中的省份
  Point targetProvince;
  //选中的城市
  Point targetCity;
  //选中的区域
  Point targetArea;

  @override
  void initState() {
    super.initState();
    provinces= new Provinces(metaInfo: widget.provincesData).provinces;
    cityTree = new CityTree(
      metaInfo: widget.citiesData,provincesInfo: widget.provincesData
    );
    itemList = provinces;
    pageStatus = Status.Province;

  }

  Future<bool> back() {
    HistoryPageInfo last = _history.length > 0 ? _history.last : null;
    if (last != null && mounted) {
      this.setState(() {
        pageStatus = last.status;
        itemList = last.itemList;
      });
      _history.removeLast();
      return Future<bool>.value(false);
    }
    return Future<bool>.value(true);
  }

  Result _buildResult() {
    Result result = Result();
    try {
        result.provinceId = targetProvince.code.toString();
        result.provinceName = targetProvince.name;
        result.cityId = targetCity != null ? targetCity.code.toString() : null;
        result.cityName = targetCity != null ? targetCity.name : null;
        result.areaId = targetArea != null ? targetArea.code.toString() : null;
        result.areaName = targetArea != null ? targetArea.name : null;
    } catch (e) {
      // 此处兼容, 部分城市下无地区信息的情况
    }

    // 台湾异常数据. 需要过滤
    if (result.provinceId == "710000") {
      result.cityId = null;
      result.cityName = null;
      result.areaId = null;
      result.areaName = null;
    }
    return result;
  }
  popHome() {
    Navigator.of(context).pop(_buildResult());
  }

  _onProvinceSelect(Point province) {
    this.setState(() {
      targetProvince = cityTree.initTree(province.code);
    });
  }

  _onAreaSelect(Point area) {
    this.setState(() {
      targetArea = area;
    });
  }

  _onCitySelect(Point city) {
    this.setState(() {
      targetCity = city;
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(ScreenUtil().setHeight(88)+MediaQuery.of(context).padding.top),
        child: AppBar(
          title: Text('1111'),
          flexibleSpace: Image(
            image: AssetImage('assets/images/login_navigation.png'),
            fit: BoxFit.cover,
          ),
          backgroundColor: Colors.transparent,
          centerTitle: true,
          elevation: 0,
        ),
      ),
      body: Container(
        child:CustomScrollView(
          slivers: <Widget>[
            buildListView(),
          ],
        ),
        padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(40)),
      )
    );
  }
  buildListView(){
   return SliverList(
     delegate: SliverChildBuilderDelegate(
         (BuildContext context,int index){
           if(index.isOdd){
             return Divider(height: 0,);
           }
           return ListTile(title: Text(provincesData.entries.elementAt(index~/2).value),);
         },childCount: provincesData.keys.length*2-1,
     ));
  }
}