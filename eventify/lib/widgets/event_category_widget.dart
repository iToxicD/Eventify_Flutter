import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Clase que representa un widget para eventos según su categoría
class EventCategoryWidget extends StatelessWidget {
  final String category;
  final String imageUrl;
  final String title;
  final DateTime startTime;

  const EventCategoryWidget({
    Key? key,
    required this.category,
    required this.imageUrl,
    required this.title,
    required this.startTime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (category) {
      case 'Music':
        return _buildMusicEventCard();
      case 'Sport':
        return _buildSportsEventCard();
      case 'Tech':
        return _buildTechEventCard();
      default:
        return const SizedBox(); // Retornar vacío si no coincide con ninguna categoría
    }
  }

  // Widget para eventos de Música
  Widget _buildMusicEventCard() {
    return Card(
      borderOnForeground: true,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Color(0xFFFFD700), width: 5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Image.network(imageUrl, fit: BoxFit.cover),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            Text(
              DateFormat('yyyy-MM-dd – kk:mm').format(startTime),
              style: const TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  // Widget para eventos de Deporte
  Widget _buildSportsEventCard() {
    return Card(
      borderOnForeground: true,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Color(0xFFFF4500), width: 5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Image.network(imageUrl, fit: BoxFit.cover),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            Text(
              DateFormat('yyyy-MM-dd – kk:mm').format(startTime),
              style: const TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  // Widget para eventos de Tecnología
  Widget _buildTechEventCard() {
    return Card(
      borderOnForeground: true,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Color(0xFF4CAF50), width: 5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Image.network(imageUrl, fit: BoxFit.cover),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            Text(
              DateFormat('yyyy-MM-dd – kk:mm').format(startTime),
              style: const TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
