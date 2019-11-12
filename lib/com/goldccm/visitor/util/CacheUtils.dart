import 'dart:io';
import 'package:path_provider/path_provider.dart';
//缓存类
//用于设置中的清除缓存功能
class CacheUtils{

  //加载缓存
  loadCache() async {
    Directory tempDir = await getTemporaryDirectory();
    double value = await _getTotalSizeOfFilesInDir(tempDir);
    print('临时目录大小'+value.toString());
    return _renderSize(value);
  }

  _getTotalSizeOfFilesInDir(FileSystemEntity file) async {
    if(file is File){
      int length = await file.length();
      return double.parse(length.toString());
    }
    if(file is Directory){
      List<FileSystemEntity> children = file.listSync();
      double total=0;
      if(children!=null){
        for(FileSystemEntity child in children){
          total += await _getTotalSizeOfFilesInDir(child);
        }
        return total;
      }
    }
    return 0;
  }
  Future clearCache() async {
    Directory tempDir = await getTemporaryDirectory();
    await delDir(tempDir);
  }

  Future delDir(FileSystemEntity file) async {
    if(file is Directory){
      List<FileSystemEntity> children = file.listSync();
      for(FileSystemEntity child in children){
        await delDir(child);
      }
    }
    await file.delete();
  }
  //格式化文件大小
  _renderSize(double value) {
    if (null == value) {
      return 0;
    }
    List<String> unitArr = List()
      ..add('B')
      ..add('K')
      ..add('M')
      ..add('G');
    int index = 0;
    while (value > 1024) {
      index++;
      value = value / 1024;
    }
    String size = value.toStringAsFixed(2);
    return size + unitArr[index];
  }
}