import 'package:meta/meta.dart';
import 'dart:convert';


class PickInfo{
   String imageFileName;
   String name;
   String idNo;
   String address;
   String bankCardNo;
   String bank;
   String path;

  PickInfo({
     this.imageFileName,
     this.name,
     this.idNo,
     this.address,
     this.bankCardNo,
     this.bank,
     this.path,
  });

  PickInfo.fromJson(Map json){
    imageFileName = json['imageFileName'];
    name = json['name'];
    idNo = json['idNo'];
    address = json['address'];
    bankCardNo = json['bankCardNo'];
    bank = json['bank'];
    path = json['path'];
  }

}