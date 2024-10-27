import 'package:eventify/screens/config_users.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Lateralmenu extends StatefulWidget {
  const Lateralmenu({super.key});

  @override
  State<Lateralmenu> createState() => _LateralmenuState();
}

class _LateralmenuState extends State<Lateralmenu> {
  int menuIndex = 1;
  @override
  Widget build(BuildContext context) {
    return NavigationDrawer(
        selectedIndex: menuIndex,
        onDestinationSelected: (value) {
          setState(() {
            menuIndex = value;
          });
          // Navigator.of(context).push(
          //   MaterialPageRoute(builder: (context) => const ConfigUsers()),
          // );
        },
        children: const [
          Padding(
            padding: EdgeInsets.fromLTRB(25, 0, 16, 10),
            child: Text("Menú principal"),
          ),
          Padding(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 10),
              child: Divider()),
          NavigationDrawerDestination(
            icon: Icon(Icons.account_circle),
            label: Text("Usuarios"),
          ),
          NavigationDrawerDestination(
              icon: Icon(Icons.settings), label: Text("Configuración")),
        ]);
  }
}
