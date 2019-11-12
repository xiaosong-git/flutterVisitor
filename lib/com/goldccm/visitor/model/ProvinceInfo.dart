import 'package:meta/meta.dart';
import 'dart:convert';


class ProvinceInfo{
  final String name;
  final List<CityInfo> cityList;

  ProvinceInfo({
     this.name,
     this.cityList,
});


}


class CityInfo{
  final String name;
  final List<String> areaList;

  CityInfo({
     this.name,
     this.areaList,
});


}