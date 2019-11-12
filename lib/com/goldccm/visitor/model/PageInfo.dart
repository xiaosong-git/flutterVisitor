import 'package:meta/meta.dart';
import 'dart:convert';

class PageInfo<T>{
   int pageNum;
   int pageSize;
   int totalPage;
   int total;
   T rows;

  PageInfo({
     this.pageNum,
     this.pageSize,
     this.totalPage,
     this.total,
     this.rows,
});

   PageInfo.fromJson(Map json){
     this.pageNum=json['pageNum'];
     this.pageSize=json['pageSize'];
     this.totalPage=json['totalPage'];
     this.total=json['total'];
     this.rows=json['rows'];
   }


}