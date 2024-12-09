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
  String _role = 'u'; // Por defecto 'usuario'

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.currentIndex;
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _role = prefs.getString('role') ?? 'u';
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Define rutas según el rol
    List<String> routes;
    if (_role == 'a') {
      routes = ['/users', '/informe', '/events', '/login'];
    } else if (_role == 'o') {
      routes = ['/events', '/graphs', '/login'];
    } else {
      routes = ['/events', '/myEvents', '/informe', '/login'];
    }

    // Navegación
    if (index < routes.length) {
      Navigator.pushReplacementNamed(context, routes[index]);
    } else {
      Authentication.logout();
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  List<BottomNavigationBarItem> _buildNavigationItems() {
    if (_role == 'a') {
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
    } else if (_role == 'o') {
      return [
        const BottomNavigationBarItem(
          icon: Icon(Icons.event),
          label: 'Eventos',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart),
          label: 'Gráficas',
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
          icon: Icon(Icons.event),
          label: 'Mis Eventos',
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
            offset: Offset(0, -4),
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
