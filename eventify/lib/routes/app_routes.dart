import 'package:flutter/material.dart';
import '../screens/register_screen.dart';
import '../screens/userlist_screen.dart';
import '../screens/login_screen.dart';

class AppRoutes {
  static const String listUser = '/users';
  static const String login = '/login';
  static const String register = '/register';

  static final routes = <String, WidgetBuilder>{
    listUser: (context) => const UserListScreen(),
    login: (context) => const LoginScreen(),
    register: (context) => const RegisterScreen(),
  };
}
