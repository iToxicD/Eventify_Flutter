import 'dart:convert';
import 'package:eventify/widgets/event_category_widget.dart';
import 'package:eventify/widgets/menu.dart';
import 'package:eventify/provider/event_provider.dart';
import 'package:flutter/material.dart';

class EventListOrganizerScreen extends StatefulWidget {
  const EventListOrganizerScreen({super.key});

  @override
  _EventListOrganizerScreenState createState() =>
      _EventListOrganizerScreenState();
}

class _EventListOrganizerScreenState extends State<EventListOrganizerScreen> {
  List<dynamic> events = [];

  @override
  void initState() {
    super.initState();
    fetchEvents();
  }

  Future<void> fetchEvents() async {
    try {
      var eventsResponse = await EventProvider.getEventsByOrganizer();

      if (eventsResponse.statusCode == 200) {
        Map<String, dynamic> jsonResponse = jsonDecode(eventsResponse.body);
        List<dynamic> fetchedEvents = jsonResponse['data'];

        // Filtrar eventos futuros y ordenar por fecha de inicio
        fetchedEvents = fetchedEvents
            .where((event) {
          DateTime start = DateTime.parse(event['start_time']);
          return start.isAfter(DateTime.now());
        })
            .toList()
          ..sort((a, b) {
            DateTime startA = DateTime.parse(a['start_time']);
            DateTime startB = DateTime.parse(b['start_time']);
            return startA.compareTo(startB);
          });

        setState(() {
          events = fetchedEvents;
        });
      } else {
        showErrorSnackBar('Error al cargar eventos creados');
      }
    } catch (e) {
      showErrorSnackBar('Error de conexión');
    }
  }

  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Eventos creados',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xff620091),
        shadowColor: Colors.grey[700],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff620091), Color(0xff8a0db7), Color(0xffb11adc)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: events.isEmpty
            ? const Center(
          child: Text(
            'No tienes eventos futuros',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        )
            : ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index];
            return GestureDetector(
              onTap: () {
                // Acción al tocar la tarjeta (opcional, según necesidad)
              },
              child: EventCategoryWidget(
                category: event['category_name'] ?? 'Sin categoría',
                imageUrl: event['image_url'] ?? '',
                title: event['title'] ?? 'Sin título',
                startTime: DateTime.parse(event['start_time']),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Acción para crear un nuevo evento
        },
        backgroundColor: const Color(0xff8a0db7),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: const Menu(currentIndex: 0),
    );
  }
}
