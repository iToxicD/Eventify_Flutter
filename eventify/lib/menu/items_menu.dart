import 'package:flutter/material.dart';

class ItemsMenu {
  final String title;
  final String link;
  final IconData icon;

  const ItemsMenu(
      {required this.title, required this.link, required this.icon});
}

const itemsMenuApp = <ItemsMenu>[
  ItemsMenu(title: "Usuarios", link: "/config_users", icon: Icons.account_box),
  ItemsMenu(
      title: "Configuración", link: "/configuration", icon: Icons.settings),
];
