import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';
import 'package:visitor/com/goldccm/visitor/util/LocalStorage.dart';
import 'package:visitor/com/goldccm/visitor/util/PremissionHandlerUtil.dart';
import 'package:contacts_service/contacts_service.dart';
class ContactsUtil{
  factory ContactsUtil() => _csUtil();

  static ContactsUtil get instance => _csUtil();

  static ContactsUtil _cUtil;

  ContactsUtil._internal();

  static ContactsUtil _csUtil(){
    if(_cUtil==null){
      _cUtil=ContactsUtil._internal();
    }
    return _cUtil;
  }
  getContacts() async {
    bool value=await PermissionHandlerUtil().askContactPermission();
    if (value) {
      String _phoneStr = await LocalStorage.load("phoneStr");
        if (_phoneStr != "" && _phoneStr != null) {
          return _phoneStr;
        }
      _phoneStr = await updateContacts();
      return _phoneStr;
    }else{
      return "";
    }
  }
  updateContacts() async {
    String _phoneStr = "";
    Iterable<Contact> contacts = await ContactsService.getContacts(withThumbnails: false,);
    for (Contact contact in contacts) {
      for (var phone in contact.phones) {
        if (phone != null && phone.value != null) {
          String str = "";
          var cuts = phone.value.split(" ");
          for (var cut in cuts) {
            str = str + cut;
          }
          RegExp exp = RegExp('\^[0-9]*\$');
          if (exp.hasMatch(str)) {
            _phoneStr += str + ",";
          }
        }
      }
    }
    LocalStorage.save("phoneStr", _phoneStr);
    return _phoneStr;
  }
  updateContactsBackground(){
    PermissionHandlerUtil().askContactPermission().then((value) async {
      if (value) {
        updateContacts();
      }
    });
  }
}