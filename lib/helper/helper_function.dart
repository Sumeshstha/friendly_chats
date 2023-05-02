import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HelperFunction{
  static String  userLoggedIn= "userLoggedIn";
  static String userEmail = "userEmail";
  static String userName = "name";

  static Future<bool>saveLoggedInStatus(isLoggedIn)async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return await sf.setBool(userLoggedIn ,isLoggedIn );
  }

  static  Future<bool> saveUserName(String username)async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return await sf.setString(userName, username);
  }

  static Future<bool>saveUserEmail(String useremail)async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return await sf.setString(userEmail, useremail);
  }

  static Future<bool?>getUserLoggedInStatus()async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return await sf.getBool(userLoggedIn);
  }

  static Future<String?>getUsername()async {
    SharedPreferences s = await SharedPreferences.getInstance();
    return s.getString(userName);
  } 

  static Future<String?> getUserEmail() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.getString(userEmail);
  }

  

}