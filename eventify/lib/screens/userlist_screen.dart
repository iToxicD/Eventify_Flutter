import 'dart:convert';
import 'package:eventify/menu/menu.dart';
import 'package:eventify/screens/update_user_screen.dart';
import 'package:eventify/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  List<dynamic> users = []; // Lista para almacenar los usuarios

  @override
  void initState() {
    super.initState();
    fetchUsers(); // Llamada inicial para obtener los usuarios
  }

  Future<void> fetchUsers() async {
    var response = await UserService.getUsers();
    if (response.statusCode == 200) {
      // Si la solicitud es exitosa, extraemos los datos del JSON
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      setState(() {
        users = jsonResponse['data']; // Almacenamos los usuarios en la lista
      });
    } else {
      // Manejo de errores en caso de respuesta fallida
      print('Error: ${response.statusCode}');
      print('Mensaje: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Usuarios'),
        backgroundColor: const Color(0xff415993),
        shadowColor: Colors.grey[700],
      ),
      drawer: const Menu(),
      body: users.isEmpty
          ? const Center(
              child: CircularProgressIndicator(), // Cargando
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: users.length,
              itemBuilder: (context, index) {
                // Extraemos cada usuario de la lista
                var user = users[index];
                return Slidable(
                  key: ValueKey(
                      user['id']), // Asegúrate de que sea una clave única
                  startActionPane: ActionPane(
                    motion: const ScrollMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (context) {
                          // Acción para editar
                        },
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        icon: Icons.task_alt,
                      ),
                      SlidableAction(
                        onPressed: (context) {
                          // Acción para desactivar
                        },
                        backgroundColor: Colors.yellow.shade700,
                        foregroundColor: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        icon: Icons.close,
                      ),
                      SlidableAction(
                        onPressed: (context) {
                          // Navegar a la pantalla de edición
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UpdateUserScreen(
                                userId: user['id'].toString(),
                                userName: user['name'],
                              ),
                            ),
                          );
                        },
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        icon: Icons.edit,
                      ),
                      SlidableAction(
                        onPressed: (context) {
                          // Acción para eliminar
                        },
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        icon: Icons.delete,
                      ),
                    ],
                  ),
                  child: Card(
                    color: const Color(0xff162340),
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      title: Text(
                        user['name'] ?? 'Nombre no disponible',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        user['email'] ?? 'Email no disponible',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      trailing: Text(
                        user['role'] ?? 'Rol no disponible',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
