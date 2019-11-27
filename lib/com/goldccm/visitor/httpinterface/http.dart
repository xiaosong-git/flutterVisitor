import 'package:dio/dio.dart';
import 'package:visitor/com/goldccm/visitor/util/Constant.dart';//用于配置公用常量
import 'package:visitor/com/goldccm/visitor/util/ToastUtil.dart';
/*
 *  Http连接
 *  author:hwk<hwk@growingpine.com>
 *  create_time:2019/11/21
 */
class Http{
  factory Http() =>_getInstance();
  static Http get instance => _getInstance();
  static Http _instance;
  Dio _dio;
  Http._internal() {
    _dio = new Dio();
    _dio.options.baseUrl = Constant.serverUrl;
    _dio.options.connectTimeout = 5000; //5s
    _dio.options.receiveTimeout = 3000;
  }
  static Http _getInstance() {
    if (_instance == null) {
      _instance = new Http._internal();
    }
    return _instance;
  }
  // get 请求封装 需要token验证
  Future<String> get(url,{ options, cancelToken, queryParameters,debugMode=true}) async {
    if(debugMode==true){
      print('get:::url：$url ,body: $queryParameters');
    }
    Response response;
    try{
      response = await _dio.get(
        url,
       // cancelToken:cancelToken,
        options: Options(method:"GET"),
        queryParameters: queryParameters !=null ? queryParameters : {},
      );
      if(debugMode==true){
        print(response);
      }
    }on DioError catch(e){
      ToastUtil.showShortToast("网络请求错误");
      if(CancelToken.isCancel(e)){
        print('get请求取消! ' + e.message);
      }else{
        print('get请求发生错误：$e');
      }
    }
    return response.data??"";
  }

  // post请求封装
  post(url,{ options, cancelToken, queryParameters,data,debugMode=true}) async {
    if(debugMode==true){
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
      if(debugMode==true){
        print(response);
      }
    }on DioError catch(e){
      ToastUtil.showShortToast("网络请求错误");
      if(CancelToken.isCancel(e)){
        print('get请求取消! ' + e.message);
      }else{
        print('get请求发生错误：$e');
      }
    }
    return response.data??"";
}
  // post请求封装
  postExt(url,{ options, cancelToken, queryParameters,data,Map<String,dynamic> headers,debugMode=true}) async {
    if(debugMode==true){
      print('post:::url：$url ,body: $queryParameters');
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
      if(debugMode==true){
        print(response);
      }
    }on DioError catch(e){
      ToastUtil.showShortToast("网络请求错误");
      if(CancelToken.isCancel(e)){
        print('get请求取消! ' + e.message);
      }else{
        print('get请求发生错误：$e');
      }
    }
    return response.data??"";
  }
}
