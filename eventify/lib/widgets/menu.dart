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

    List<String> routes = _isAdmin
        ? ['/users', '/informe', '/events', '/login']
        : ['/events', '/informe', '/login'];

    switch (index) {
      case 0:
      case 1:
      case 2:
        Navigator.pushReplacementNamed(context, routes[index]);
        break;
      case 3:
        Authentication.logout();
        Navigator.pushReplacementNamed(context, routes[index]);
        break;
    }

  }

  List<BottomNavigationBarItem> _buildNavigationItems() {
    if (_isAdmin) {
      return [
        const BottomNavigationBarItem(
          icon: Icon(Icons.account_box),
          label: 'Usuarios',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.edit_document),
          label: 'Informe',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.event),
          label: 'Eventos',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.logout),
          label: 'Logout',
        ),
      ];
    } else {
      return [
        const BottomNavigationBarItem(
          icon: Icon(Icons.event),
          label: 'Eventos',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.edit_document),
          label: 'Informe',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.logout),
          label: 'Logout',
        ),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, -4), // Sombra hacia arriba
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black,
        selectedIconTheme: const IconThemeData(color: Colors.black),
        unselectedIconTheme: const IconThemeData(color: Colors.black),
        showUnselectedLabels: true,
        items: _buildNavigationItems(),
        
      ),
    );
  }
}
