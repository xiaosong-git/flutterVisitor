import 'package:dio/dio.dart';
import 'package:visitor/com/goldccm/visitor/util/Constant.dart';//用于配置公用常量
import 'package:visitor/com/goldccm/visitor/util/SharedPreferenceUtil.dart';
import 'package:visitor/com/goldccm/visitor/util/TimerUtil.dart';
import 'package:visitor/com/goldccm/visitor/util/ToastUtil.dart';
/*
 *  Http连接
 *  author:hwk<hwk@growingpine.com>
 *  create_time:2019/11/21
 *  block 请求锁
 */
class Http{
  factory Http() =>_getInstance();
  static Http get instance => _getInstance();
  static Http _instance;
  static TimerUtil _timerUtil;
  static bool block;
  Dio _dio;
  Http._internal() {
    _dio = new Dio();
    _dio.options.baseUrl = Constant.serverUrl;
    _dio.options.connectTimeout = 5000;
    _dio.options.receiveTimeout = 5000;
    block=false;
    _timerUtil=new TimerUtil(mInterval: 2);
    _timerUtil.setOnTimerTickCallback((tap){
      block=false;
      _timerUtil.cancel();
    });
  }

  static Http _getInstance() {
    if (_instance == null) {
      _instance = new Http._internal();
    }
    return _instance;
  }
  // get 请求封装 需要token验证
  Future<String> get(url,{ options, cancelToken, queryParameters,bool debugMode=true,bool userCall=false}) async {
    if(userCall){
      if(block){
        return "";
      }
      block=true;
      _timerUtil.startTimer();
    }
    if(debugMode==true){
      print('get:::url：$url ,body: $queryParameters');
    }
    Response response;
    try{
      response = await _dio.get(
        url,
        options: Options(method:"GET"),
        queryParameters: queryParameters !=null ? queryParameters : {},
      );
      if(debugMode==true){
        print(response);
      }
      return response.data;
    }on DioError catch(e){
      ToastUtil.showShortToast("网络请求错误");
      if(CancelToken.isCancel(e)){
        print('get请求取消! ' + e.message);
      }else{
        print('get请求发生错误：$e');
      }
    }
    return "";
  }

  // post请求封装
  post(url,{ options, cancelToken, queryParameters,data,bool debugMode=true,bool userCall=false}) async {
    if(userCall){
      if(block){
        print("禁止反复请求");
        return "";
      }
      block=true;
      _timerUtil.startTimer();
    }
    if(debugMode){
      print('post:::url：$url ,body: $queryParameters');
    }
    Response response=new Response();
    try{
      response = await _dio.post(
          url,
          queryParameters:queryParameters !=null ? queryParameters : {},
          cancelToken:cancelToken,
          data:data!=null?data:{},
      );
      if(debugMode){
        print(response);
      }
      return response.data;
    }on DioError catch(e){
      ToastUtil.showShortToast("网络请求错误");
      if(CancelToken.isCancel(e)){
        print('post请求取消! ' + e.message);
      }else{
        print('post请求发生错误：$e');
      }
    }
    return "";
}
  // post请求封装
  postExt(url,{ options, cancelToken, queryParameters,data,Map<String,dynamic> headers,bool debugMode=true,bool userCall=false}) async {
    if(userCall){
      if(block){
        return "";
      }
      block=true;
      _timerUtil.startTimer();
    }
    if(debugMode){
      print('postExt:::url：$url ,body: $queryParameters');
    }
    Response response;
    _dio.options.headers.addAll(headers);
    try{
      response = await _dio.post(
        url,
        queryParameters:queryParameters !=null ? queryParameters : {},
        cancelToken:cancelToken,
        data:data!=null?data:{},
      );
      if(debugMode){
        print(response);
      }
      return response.data;
    }on DioError catch(e){
      ToastUtil.showShortToast("网络请求错误");
      if(CancelToken.isCancel(e)){
        print('postExt请求取消! ' + e.message);
      }else{
        print('postExt请求发生错误：$e');
      }
    }
    return "";
  }
}
