import 'package:flutter/material.dart';
import 'package:eventify/provider/user_provider.dart';

class UpdateUserScreen extends StatefulWidget {
  final String userId;
  final String userName;

  const UpdateUserScreen({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  _UpdateUserScreenState createState() => _UpdateUserScreenState();
}

class _UpdateUserScreenState extends State<UpdateUserScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _idController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userName);
    _idController = TextEditingController(text: widget.userId);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _idController.dispose();
    super.dispose();
  }

  Future<void> _updateUser() async {
    if (_formKey.currentState!.validate()) {
      var response = await UserProvider.updateUser(
        widget.userId,
        _nameController.text,
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuario actualizado correctamente')),
        );
        Navigator.pop(context); // Regresar a la lista de usuarios
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.statusCode}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Actualizar Usuario',
          style: TextStyle(fontSize: 25, color: Colors.white),
        ),
        backgroundColor: const Color(0xff620091),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _idController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'ID de usuario',
                  labelStyle: TextStyle(color: Colors.black, fontSize: 22),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(),
                ),
                style: const TextStyle(color: Colors.black),
              ),
              const SizedBox(height: 35), // Espacio entre ID y Nombre
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  labelStyle: TextStyle(color: Colors.black, fontSize: 22),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingresa un nombre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30), // Espacio entre el Nombre y el Botón
              ElevatedButton(
                onPressed: _updateUser,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(200, 80),
                  backgroundColor: const Color(0xffc86ee1),
                ),
                child: const Text(
                  'Actualizar',
                  style: TextStyle(fontSize: 25, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
