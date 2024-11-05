import 'package:eventify/provider/authentication.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Menu extends StatelessWidget {
  const Menu({super.key});

  Future<bool> _isAdmin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? role = prefs.getString('role');
    return role == 'a'; // Compara el rol con el valor de admin
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: FutureBuilder<bool>(
        future: _isAdmin(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xff620091), Color(0xff8a0db7), Color(0xffb11adc)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Text(
                  'Menú',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('Home'),
                onTap: () {
                  Navigator.pushNamed(context, '/home');
                },
              ),
              // Mostrar "Users" solo si el usuario es administrador
              if (snapshot.data == true)
                ListTile(
                  leading: const Icon(Icons.account_box),
                  title: const Text('Users'),
                  onTap: () {
                    Navigator.pushNamed(context, '/users');
                  },
                ),
              ListTile(
                leading: const Icon(Icons.event),
                title: const Text('Eventos'),
                onTap: () {
                  Navigator.pushNamed(context, '/events');
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: () {
                  Authentication.logout();
                  Navigator.pushNamed(context, '/login');
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
