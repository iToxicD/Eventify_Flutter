import 'package:flutter/material.dart';
import '../screens/register_screen.dart';
import '../screens/userlist_screen.dart';
import '../screens/home_screen.dart';
import '../screens/login_screen.dart';

class AppRoutes {
  static const String home = '/home';
  static const String listUser = '/users';
  static const String login = '/login';
  static const String register = '/register';

  static final routes = <String, WidgetBuilder>{
    home: (context) => HomeScreen(),
    listUser: (context) => UserListScreen(),
    login: (context) => LoginScreen(),
    register: (context) => RegisterScreen(),
  };
}
