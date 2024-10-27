import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class ConfigUsers extends StatelessWidget {
  const ConfigUsers({super.key});

  final List<String> users = const [
    "Pablo",
    "Lucia",
    "Juan",
    "Laura"
  ]; // Lista de usuarios de ejemplo

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (BuildContext context, int index) {
        return Slidable(
          key: ValueKey(users[index]),
          endActionPane: ActionPane(
            motion: const ScrollMotion(),
            children: [
              // Botón activar
              SlidableAction(
                flex: 3,
                onPressed: (context) {},
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                icon: Icons.account_circle,
                label: 'Activar',
              ),

              // Botón desactivar
              SlidableAction(
                flex: 3,
                onPressed: (context) {},
                backgroundColor: Colors.amber,
                foregroundColor: Colors.white,
                icon: Icons.account_circle_outlined,
                label: 'Desactivar',
              ),

              // Botoón editar
              SlidableAction(
                flex: 3,
                onPressed: (context) {
                  _showEditUser(context, users[index]);
                },
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                icon: Icons.edit,
                label: 'Editar',
              ),

              // Botón de Eliminar
              SlidableAction(
                flex: 3,
                onPressed: (context) {
                  _showDeleteUser(context, users[index]);
                },
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                icon: Icons.delete,
                label: 'Eliminar',
              ),
            ],
          ),

          // Contenido principal del ListTile
          child: ListTile(
            title: Text(users[index]),
            leading: const Icon(Icons.person),
          ),
        );
      },
    );
  }
}

// Función para mostrar el diálogo de confirmación de eliminación
void _showDeleteUser(BuildContext context, String user) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Confirmar eliminación"),
        content: Text("¿Estás seguro de que deseas eliminar a $user?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(), // Cerrar el diálogo
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () {
              // Lógica para eliminar el usuario
              Navigator.of(context).pop();
            },
            child: const Text("Eliminar"),
          ),
        ],
      );
    },
  );
}

// Función para mostrar el diálogo de edición
void _showEditUser(BuildContext context, String user) {
  final TextEditingController controller = TextEditingController(text: user);

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Editar usuario"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: "Nombre del usuario"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(), // Cerrar el diálogo
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () {
              // Lógica para guardar el nombre editado
              Navigator.of(context).pop();
            },
            child: const Text("Guardar"),
          ),
        ],
      );
    },
  );
}
