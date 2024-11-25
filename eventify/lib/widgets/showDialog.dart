import 'package:flutter/material.dart';

class showEventDialog extends StatelessWidget {
  final Map<String, dynamic> event;
  final VoidCallback? registerEvents; 
  final VoidCallback? unRegisterEvents;

  const showEventDialog({
    super.key,
    required this.event,
    this.registerEvents,
    this.unRegisterEvents,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(event['title'] ?? 'Título no disponible'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (event['image_url'] != null && event['image_url'].isNotEmpty)
              Image.network(event['image_url']),
            const SizedBox(height: 10),
            Text('Categoría: ${event['category'] ?? 'No disponible'}'),
            const SizedBox(height: 10),
            Text('Descripción: ${event['description'] ?? 'No disponible'}'),
            const SizedBox(height: 10),
            Text(
                'Fecha: ${event['start_time'] != null ? DateTime.parse(event['start_time']).toLocal().toString() : 'No disponible'}'),
            const SizedBox(height: 10),
            Text('Ubicación: ${event['location'] ?? 'No disponible'}'),
            const SizedBox(height: 10),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cerrar'),
        ),
        // Muestra para que el usuario se pueda registrar al evento
        if (registerEvents != null)
          ElevatedButton(
            onPressed: () {
              registerEvents!(); 
              Navigator.of(context).pop(); 
            },
            child: const Text('Registrarse'),
          ),
        // Muestra para que el usuario se borre del evento
        if (unRegisterEvents != null) 
          ElevatedButton(
            onPressed: () {
              unRegisterEvents!(); 
              Navigator.of(context).pop(); 
            },
            child: const Text('Borrarse'),
          ),
      ],
    );
  }
}
