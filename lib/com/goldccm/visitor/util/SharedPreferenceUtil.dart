import 'package:visitor/com/goldccm/visitor/model/UserInfo.dart';
import 'package:shared_preferences/shared_preferences.dart';

///数据库相关的工具
class SharedPreferenceUtil {
  static const String ACCOUNT_NUMBER = "account_number";
  static const String USERNAME = "username";
  static const String PASSWORD = "password";
  static const String TOKEN ="token";

  ///删掉单个账号
  static void delUser(UserInfo user) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    List<UserInfo> list = await getUsers();
    list.remove(user);
    saveUsers(list, sp);
  }

  ///保存账号，如果重复，就将最近登录账号放在第一个
  static void saveUser(UserInfo user) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    List<UserInfo> list = await getUsers();
    addNoRepeat(list, user);
    saveUsers(list, sp);
  }

  ///去重并维持次序
  static void addNoRepeat(List<UserInfo> users, UserInfo user) {
    if (users.contains(user)) {
      users.remove(user);
    }
    users.insert(0, user);
  }

  ///获取已经登录的账号列表
  static Future<List<UserInfo>> getUsers() async {
    List<UserInfo> list = new List();
    SharedPreferences sp = await SharedPreferences.getInstance();
    int num = sp.getInt(ACCOUNT_NUMBER) ?? 0;
    for (int i = 0; i < num; i++) {
      String username = sp.getString("$USERNAME$i");
      String password = sp.getString("$PASSWORD$i");
      //list.add(UserInfo(username, password));
    }
    return list;
  }

  ///保存账号列表
  static saveUsers(List<UserInfo> users, SharedPreferences sp){
    sp.clear();
    int size = users.length;
    for (int i = 0; i < size; i++) {
      sp.setString("$USERNAME$i", users[i].loginName);
      //sp.setString("$PASSWORD$i", users[i]);
    }
    sp.setInt(ACCOUNT_NUMBER, size);
  }
}