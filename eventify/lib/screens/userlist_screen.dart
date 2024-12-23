import 'dart:convert';
import 'package:eventify/widgets/menu.dart';
import 'package:eventify/screens/update_user_screen.dart';
import 'package:eventify/provider/user_provider.dart';
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
    var response = await UserProvider.getUsers();
    if (response.statusCode == 200) {
      // Si la solicitud es exitosa, extraemos los datos del JSON
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      setState(() {
        users = jsonResponse['data']; // Almacenamos los usuarios en la lista
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Lista de Usuarios',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xff620091),
        shadowColor: Colors.grey[700],
      ),
      // Cambiar el fondo de la pantalla al color degradado del appBar
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff620091), Color(0xff8a0db7), Color(0xffb11adc)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: users.isEmpty
            ? const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ), // Cargando
              )
            : ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: users.length,
                itemBuilder: (context, index) {
                  // Extraemos cada usuario de la lista
                  var user = users[index];
                  return Slidable(
                    key: ValueKey(user['id']),
                    startActionPane: ActionPane(
                      motion: const ScrollMotion(),
                      children: [
                        user['actived'] == 0
                            ? SlidableAction(
                                onPressed: (context) {
                                  _activateUser(user['id'].toString());
                                },
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                icon: Icons.task_alt,
                              )
                            : SlidableAction(
                                onPressed: (context) {
                                  _deactivateUser(user['id'].toString());
                                },
                                backgroundColor: Colors.yellow.shade700,
                                foregroundColor: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                icon: Icons.close,
                              ),
                        SlidableAction(
                          onPressed: (context) async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UpdateUserScreen(
                                  userId: user['id'].toString(),
                                  userName: user['name'],
                                ),
                              ),
                            );
                            fetchUsers();
                          },
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          icon: Icons.edit,
                        ),
                        SlidableAction(
                          onPressed: (context) {
                            confirmDeleteUser(user['id'].toString());
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
                      color: Colors.white, // Fondo blanco para la tarjeta
                      margin: const EdgeInsets.symmetric(vertical: 10.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ListTile(
                        title: Text(
                          user['name'] ?? 'Nombre no disponible',
                          style: const TextStyle(
                            color: Colors.black, // Texto en negro
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        subtitle: Text(
                          user['email'] ?? 'Email no disponible',
                          style: const TextStyle(
                              color: Colors.black54, fontSize: 15),
                        ),
                        trailing: Text(
                          user['role'] ?? 'Rol no disponible',
                          style: const TextStyle(
                              color: Colors.black, fontSize: 20),
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
      bottomNavigationBar: const Menu(currentIndex: 2),
    );
  }

  void confirmDeleteUser(String userId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirmar eliminación"),
          content:
              const Text("¿Estás seguro de que deseas eliminar este usuario?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el cuadro de diálogo
              },
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el cuadro de diálogo
                deleteUserHandler(userId); // Llama a la función de eliminación
              },
              child: const Text("Eliminar"),
            ),
          ],
        );
      },
    );
  }

  void deleteUserHandler(String userId) async {
    var response = await UserProvider.deleteUser(userId);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario eliminado correctamente')),
      );
      fetchUsers(); // Actualizar la lista de usuarios después de eliminar
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${response.statusCode}')),
      );
    }
  }

  void _activateUser(String userId) async {
    var response = await UserProvider.activateUser(userId);
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario activado con éxito')),
      );
      fetchUsers(); // Actualizar la lista de usuarios después de activar un usuario
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${response.statusCode}')),
      );
    }
  }

  void _deactivateUser(String userId) async {
    var response = await UserProvider.deactivateUser(userId);
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario desactivado con éxito')),
      );
      fetchUsers(); // Actualizar la lista de usuarios después de desactivar un usuario
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${response.statusCode}')),
      );
    }
  }
}
