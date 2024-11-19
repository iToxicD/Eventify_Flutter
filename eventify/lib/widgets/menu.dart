import 'package:eventify/provider/authentication.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Menu extends StatefulWidget {
  final int currentIndex;

  const Menu({super.key, required this.currentIndex});

  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  int _selectedIndex = 0;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.currentIndex;
    _checkAdminStatus();
  }

  Future<void> _checkAdminStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? role = prefs.getString('role');
    setState(() {
      _isAdmin = role == 'a';
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/home');
        break;
      case 1:
        if (_isAdmin) Navigator.pushNamed(context, '/users');
        break;
      case 2:
        Navigator.pushNamed(context, '/events');
        break;
      case 3:
        Authentication.logout();
        Navigator.pushNamed(context, '/login');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      backgroundColor: Colors.white,
      unselectedLabelStyle: const TextStyle(color: Colors.black),
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home, color: Colors.black),
          label: 'Inicio',
        ),
        if (_isAdmin)
          const BottomNavigationBarItem(
            icon: Icon(Icons.account_box, color: Colors.black),
            label: 'Usuarios',
          ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.event, color: Colors.black),
          label: 'Eventos',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.logout, color: Colors.black),
          label: 'Logout',
        ),
      ],
    );
  }
}
