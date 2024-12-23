import 'package:eventify/screens/eventlist_organizer_screen.dart';
import 'package:eventify/screens/eventsRegistered_screen.dart';
import 'package:eventify/screens/graph_event_screen.dart';
import 'package:eventify/screens/home_screen.dart';
import 'package:eventify/screens/informe_screen.dart';
import 'package:flutter/material.dart';
import '../middleware/role_middleware.dart';
import '../screens/register_screen.dart';
import '../screens/userlist_screen.dart';
import '../screens/login_screen.dart';

class AppRoutes {
  static const String listUser = '/users';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String listEvents = "/events";
  static const String myEvents = "/myEvents";
  static const String informe = "/informe";
  static const String graphs = "/graphs";

  static final routes = <String, WidgetBuilder>{
    home: (context) => const HomeScreen(),
    login: (context) => const LoginScreen(),
    register: (context) => const RegisterScreen(),
    listUser: (context) {
      RoleMiddleware.authorize(context, const UserListScreen());
      return const SizedBox.shrink();
    },
    listEvents: (context){
      RoleMiddleware.authorizeOrganizer(context, const EventListOrganizerScreen());
      return const SizedBox.shrink();
    },
    myEvents: (context) => const RegisteredEventsScreen(),
    informe: (context) => InformeScreen(),
    graphs: (context) => GraphEventScreen()
  };
}
