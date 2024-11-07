import 'dart:convert';
import 'package:eventify/widgets/eventlist_buttons.dart';
import 'package:eventify/widgets/menu.dart';
import 'package:eventify/provider/event_provider.dart';
import 'package:flutter/material.dart';

import '../widgets/event_category_widget.dart';

class EventListScreen extends StatefulWidget {
  const EventListScreen({super.key});

  @override
  _EventListScreenState createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  List<dynamic> events = []; // Lista para almacenar los eventos
  List<dynamic> filterEvents = [];

  @override
  void initState() {
    super.initState();
    fetchEvents(); // Llamada inicial para obtener los eventos
  }

  Future<void> fetchEvents() async {
    var response = await EventProvider.getEvents();

    if (response.statusCode == 200) {
      // Si la solicitud es exitosa, extraemos los datos del JSON
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      events = jsonResponse['data'];

      // Filtrar eventos que no han comenzado
      DateTime now = DateTime.now();
      events = events.where((event) {
        DateTime startTime = DateTime.parse(event['start_time']);
        return startTime.isAfter(now); // Solo incluir eventos futuros
      }).toList();

      // Ordenar eventos de más nuevo a más antiguo
      events.sort((a, b) {
        DateTime startTimeA = DateTime.parse(a['start_time']);
        DateTime startTimeB = DateTime.parse(b['start_time']);
        return startTimeB.compareTo(startTimeA); // Orden descendente
      });

      setState(() {
        // Almacenamos los eventos filtrados y ordenados en la lista
        filterEvents = List.from(events);
      });
    }
  }

  void eventCategories(String category) {
    setState(() {
      List.from(events);
      if (category.isEmpty) {
        // Si una categoria esta vacia muestra todos los eventos
        filterEvents = List.from(events);
      } else {
        // Filtra por categoria
        filterEvents =
            events.where((event) => event['category'] == category).toList();
      }
      print("Categoria: $category");
      print("Eventos filtrados: $filterEvents");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Lista de Eventos',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xff620091),
        shadowColor: Colors.grey[700],
      ),
      drawer: const Menu(),
      floatingActionButton: EventlistButtons(
        categories: eventCategories,
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
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: filterEvents.length,
                itemBuilder: (context, index) {
                  var event = filterEvents[index];
                  return EventCategoryWidget(
                    category: event['category'],
                    imageUrl: event['image_url'] ?? '',
                    title: event['title'] ?? 'Título no disponible',
                    startTime: DateTime.parse(event['start_time']),
                  );
                },
              ),
      ),
    );
  }
}
