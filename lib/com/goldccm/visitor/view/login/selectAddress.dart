import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:visitor/com/goldccm/visitor/meta/province.dart';
import 'package:visitor/com/goldccm/visitor/model/base_citys.dart';
import 'package:visitor/com/goldccm/visitor/model/point.dart';
import 'package:visitor/com/goldccm/visitor/model/result.dart';
import 'package:visitor/com/goldccm/visitor/util/util.dart';

//地址选择
//create_time:2020/1/25
class SelectAddressPage extends StatefulWidget{
  final Map<String,dynamic> provincesData;
  final Map<String,dynamic> citiesData;
  SelectAddressPage({this.provincesData,this.citiesData});
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
  //滑动控制器
  ScrollController scrollController;

  @override
  void initState() {
    super.initState();
    scrollController = new ScrollController();
    provinces= new Provinces(metaInfo: widget.provincesData).provinces;
    cityTree = new CityTree(
      metaInfo: widget.citiesData,provincesInfo: widget.provincesData
    );
    itemList = provinces;
    pageStatus = Status.Province;
    try {
      _initLocation();
    } catch (e) {
      print('Exception details:\n 初始化地理位置信息失败, 请检查省分城市数据 \n $e');
    }
  }
  Widget _buildHead() {
    String title = '请选择省份';
    switch (pageStatus) {
      case Status.Province:
        break;
      case Status.City:
        title = "请选择城市";
        break;
      case Status.Area:
        title = "请选择县/区";
        break;
      case Status.Over:
        break;
    }
    return Text(title,style: TextStyle(color: Color(0xFF0073FE),fontSize: ScreenUtil().setSp(36)),);
  }
  void _initLocation() {
    targetProvince =
    cityTree.initTreeByCode(int.parse(widget.provincesData.keys.first));
    if (targetCity == null) {
    targetCity = _getTargetChildFirst(targetProvince);
    }
    if (targetArea == null) {
    targetArea = _getTargetChildFirst(targetCity);
    }
  }
  Point _getTargetChildFirst(Point target) {
    if (target == null) {
      return null;
    }
    if (target.child != null && target.child.isNotEmpty) {
      return target.child.first;
    }
    return null;
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

  int _getSelectedId() {
    int selectId;
    switch (pageStatus) {
      case Status.Province:
        selectId = targetProvince.code;
        break;
      case Status.City:
        selectId = targetCity.code;
        break;
      case Status.Area:
        selectId = targetArea.code;
        break;
      case Status.Over:
        break;
    }
    return selectId;
  }

  /// 所有选项的点击事件入口
  /// @param targetPoint 被点击对象的point对象
  _onItemSelect(Point targetPoint) {
    _history.add(HistoryPageInfo(itemList: itemList, status: pageStatus));
    Status nextStatus;
    List<Point> nextItemList;
    switch (pageStatus) {
      case Status.Province:
        _onProvinceSelect(targetPoint);
        nextStatus = Status.City;
        nextItemList = targetProvince.child;
        if (nextItemList.isEmpty) {
          targetCity = null;
          targetArea = null;
          nextStatus = Status.Over;
        }
        break;
      case Status.City:
        _onCitySelect(targetPoint);
        nextStatus = Status.Area;
        nextItemList = targetCity.child;
        if (nextItemList.isEmpty) {
          targetArea = null;
          nextStatus = Status.Over;
        }
        break;
      case Status.Area:
        nextStatus = Status.Over;
        _onAreaSelect(targetPoint);
        break;
      case Status.Over:
        break;
    }

    setTimeout(
        milliseconds: 300,
        callback: () {
          if (nextItemList == null || nextStatus == Status.Over) {
            return popHome();
          }
          if (mounted) {
            this.setState(() {
              itemList = nextItemList;
              pageStatus = nextStatus;
            });
            scrollController.jumpTo(0.0);
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(ScreenUtil().setHeight(88)),
        child: AppBar(
          title: _buildHead(),
//          flexibleSpace: Image(
////            image: AssetImage('assets/images/login_navigation.png'),
////            fit: BoxFit.cover,
////          ),
          backgroundColor: Color(0xFFFFFFFF),
          centerTitle: true,
          elevation: 0,
          automaticallyImplyLeading: false,
          leading: IconButton(
              icon: Image(image: AssetImage("assets/images/login_back.png"),width: ScreenUtil().setWidth(36),height: ScreenUtil().setHeight(36),color: Color(0xFF0073FE),),
              onPressed: () {
                setState(() {
                  Navigator.pop(context);
                });
              }),
        ),
      ),
      body: SafeArea(
        bottom: true,
        child: Container(
          color: Colors.white,
          child:CustomScrollView(
            slivers: <Widget>[
              buildListView(),
            ],
            controller: scrollController,
          ),
          padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(40)),
        )
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
           return ListTile(
             title: Text(itemList[index~/2].name),
             onTap: (){
                _onItemSelect(itemList[index~/2]);
             },
//             selected: _getSelectedId() == itemList[index~/2].code,
           );
         },childCount: itemList.length*2-1,
     ),
   );
  }
}