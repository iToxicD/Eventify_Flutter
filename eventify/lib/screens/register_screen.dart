import 'dart:convert';
import 'package:eventify/screens/login_screen.dart';
import 'package:eventify/provider/authentication.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  String name = '';
  String email = '';
  String password = '';
  String confirmPassword = '';
  String role = '';

  createAccount() async {
    try {
      http.Response res =
          await Authentication.register(name, email, password, password, role);

      // Decodificar la respuesta JSON
      Map response =
          jsonDecode(res.body); // Esto lanzará un error si no es un JSON válido

      if (res.statusCode == 200 && response['success']) {
        // Redirigir al Login
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const LoginScreen(),
            ));
      } else {
        // Manejar el error (mostrar mensaje)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(response['message'] ?? 'Error en el registro')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error en la solicitud: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xff620091),
                  Color(0xff8a0db7),
                  Color(0xffb11adc)
                ],
              ),
            ),
            child: Stack(
              // Cambiamos a Stack para superponer el nuevo contenedor
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 100),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    height: double.infinity,
                    width: double.infinity,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 50),
                          const MessageWelcome(),
                          NameField(onChanged: (value) => name = value),
                          EmailField(onChanged: (value) => email = value),
                          PasswordField(onChanged: (value) => password = value),
                          ConfirmPasswordField(
                              onChanged: (value) => confirmPassword = value),
                          RoleField(onChanged: (value) => role = value ?? 'u'),
                          const SizedBox(height: 20),
                          RegisterButton(onPressed: createAccount),
                          const SizedBox(height: 20),
                          const LoginMessage(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class MessageWelcome extends StatelessWidget {
  const MessageWelcome({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 50, left: 100),
      child: ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [
          Color(0xff620091),
          Color(0xff8a0db7),
          Color(0xffb11adc),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(bounds),
      child: const Text(
        'Unete a Eventify ¡REGISTRATE!',
        style: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      ),
    );
  }
}

class NameField extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const NameField({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
      child: TextFormField(
        onChanged: onChanged,
        style: const TextStyle(color: Colors.black),
        decoration: const InputDecoration(
          icon: Icon(Icons.account_box_outlined, color: Colors.black),
          labelText: 'Nombre',
          labelStyle: TextStyle(color: Colors.black, fontSize: 22),
        ),
      ),
    );
  }
}

class EmailField extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const EmailField({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
      child: TextFormField(
        onChanged: onChanged,
        style: const TextStyle(color: Colors.black),
        decoration: const InputDecoration(
          icon: Icon(Icons.email_outlined, color: Colors.black),
          labelText: 'Correo electrónico',
          labelStyle: TextStyle(color: Colors.black, fontSize: 22),
        ),
      ),
    );
  }
}

class PasswordField extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const PasswordField({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
      child: TextFormField(
        obscureText: true,
        onChanged: onChanged,
        style: const TextStyle(color: Colors.black),
        decoration: const InputDecoration(
          icon: Icon(Icons.password_outlined, color: Colors.black),
          labelText: 'Contraseña',
          labelStyle: TextStyle(color: Colors.black, fontSize: 22),
        ),
      ),
    );
  }
}

class ConfirmPasswordField extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const ConfirmPasswordField({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
      child: TextFormField(
        obscureText: true,
        onChanged: onChanged,
        style: const TextStyle(color: Colors.black),
        decoration: const InputDecoration(
          icon: Icon(Icons.lock_outline, color: Colors.black),
          labelText: 'Confirmar Contraseña',
          labelStyle: TextStyle(color: Colors.black, fontSize: 22),
          suffixIconColor: Colors.black,
        ),
      ),
    );
  }
}

class RoleField extends StatefulWidget {
  final ValueChanged<String?> onChanged;
  const RoleField({super.key, required this.onChanged});

  @override
  _RoleFieldState createState() => _RoleFieldState();
}

class _RoleFieldState extends State<RoleField> {
  String selectedRole = 'u'; // Rol preseleccionado

  @override
  void initState() {
    super.initState();
    // Llamamos a onChanged al iniciar para asegurar que el valor predeterminado 'u' sea registrado en el estado principal
    widget.onChanged(selectedRole);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
      child: DropdownButtonFormField<String>(
        value: selectedRole,
        decoration: InputDecoration(
          labelText: 'Seleccione su rol',
          labelStyle: const TextStyle(color: Colors.black),
          filled: true,
          fillColor: Colors.black.withOpacity(0.1),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.black),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        items: const [
          DropdownMenuItem(value: 'u', child: Text("Usuario")),
          DropdownMenuItem(value: 'o', child: Text("Organizador")),
        ],
        onChanged: (value) {
          setState(() {
            selectedRole = value!;
          });
          widget.onChanged(selectedRole);
        },
        style: const TextStyle(color: Colors.black, fontSize: 25),
        dropdownColor: const Color.fromARGB(255, 223, 200, 251),
        borderRadius: BorderRadius.circular(10),
        hint: const Text(
          "Seleccione su rol",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}


class RegisterButton extends StatelessWidget {
  final VoidCallback onPressed;

  const RegisterButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(200, 80), // Aplica el tamaño mínimo
      ),
      onPressed: onPressed,
      child: const Text(
        'Registrarse',
        style: TextStyle(fontSize: 25, color: Colors.black),
      ),
    );
  }
}

class LoginMessage extends StatelessWidget {
  const LoginMessage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          '¿Ya tienes una cuenta?',
          style: TextStyle(fontSize: 20, color: Colors.black),
        ),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          },
          child: const Text(
            'Inicia sesión',
            style: TextStyle(
              fontSize: 25,
              fontStyle: FontStyle.italic,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}
