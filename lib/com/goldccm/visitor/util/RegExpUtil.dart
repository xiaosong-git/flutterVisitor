class RegExpUtil{

  factory RegExpUtil() => _regExp();

  static RegExpUtil get instance => _regExp();

  static RegExpUtil _regExpUtil;

  RegExpUtil._internal();

  static RegExpUtil _regExp(){
    if(_regExpUtil==null){
      _regExpUtil=RegExpUtil._internal();
    }
    return _regExpUtil;
  }

  bool verifyPhone(String text){
    RegExp exp = RegExp(r'^((13[0-9])|(14[0-9])|(15[0-9])|(16[0-9])|(17[0-9])|(18[0-9])|(19[0-9]))\d{8}$');
    return exp.hasMatch(text);
  }
  bool verifyPassWord(String text){
    RegExp exp = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,16}$');
    return exp.hasMatch(text);
  }
  bool verifyCode(String text){
    RegExp exp = RegExp(r'^\d{6}$');
    return exp.hasMatch(text);
  }
}