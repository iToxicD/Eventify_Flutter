import 'dart:convert';
import 'package:eventify/widgets/event_category_widget.dart';
import 'package:eventify/widgets/eventlist_buttons.dart';
import 'package:eventify/widgets/menu.dart';
import 'package:eventify/widgets/showDialog.dart';
import 'package:eventify/provider/event_provider.dart';
import 'package:flutter/material.dart';

class EventListScreen extends StatefulWidget {
  const EventListScreen({super.key});

  @override
  _EventListScreenState createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  List<dynamic> availableEvents = [];
  List<dynamic> filterEvents = [];
  String selectedCategory = 'all';

  @override
  void initState() {
    super.initState();
    fetchAvailableEvents();
  }

  Future<void> fetchAvailableEvents() async {
    try {
      var response = await EventProvider.getEvents();
      var responseRegistered = await EventProvider.getEventsByUser();

      if (response.statusCode == 200 && responseRegistered.statusCode == 200) {
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        List<dynamic> events = jsonResponse['data'];

        Map<String, dynamic> jsonResponseRegistered = jsonDecode(responseRegistered.body);
        List<dynamic> registeredEvents = jsonResponseRegistered['data'];

        List<dynamic> registeredEventIds = registeredEvents.map((e) => e['id']).toList();

        DateTime now = DateTime.now();
        DateTime tomorrow = DateTime(now.year, now.month, now.day).add(Duration(days: 2));

        // Filtramos para obtener los eventos que empiezan a partir de mañana y a los que ademas no estamos registrados
        List<dynamic> filteredEvents = events.where((event) {
          DateTime? eventStartTime = DateTime.tryParse(event['start_time'] ?? '');
          bool isUpcoming = eventStartTime != null && eventStartTime.isAfter(tomorrow.subtract(Duration(days: 1)));
          bool isNotRegistered = !registeredEventIds.contains(event['id']);
          return isUpcoming && isNotRegistered;
        }).toList();

        // Orden ascendente por fecha
        filteredEvents.sort((a, b) {
          DateTime startA = DateTime.parse(a['start_time']);
          DateTime startB = DateTime.parse(b['start_time']);
          return startA.compareTo(startB);
        });

        setState(() {
          availableEvents = filteredEvents; // Solo los eventos no registrados y futuros
          filterEvents = List.from(availableEvents); // Inicialmente, muestra todos
        });
      } else {
        showErrorSnackBar('Error al cargar eventos disponibles o registrados');
      }
    } catch (e) {
      showErrorSnackBar('Error de conexión');
    }
  }




  // Función para filtrar eventos por categoría
  void filterEvent(String category) {
    setState(() {
      selectedCategory = category; // Actualiza la categoría seleccionada
      if (category == 'all') {
        filterEvents = List.from(availableEvents); // Mostrar todos los eventos
      } else {
        filterEvents = availableEvents
            .where((event) => event['category'] == category).toSet()
            .toList(); // Filtra por categoría
      }
    });
  }

  // Registro en un evento
  Future<void> registerEvent(dynamic event) async {
    try {
      var response = await EventProvider.register(event['id']);

      if (response.statusCode == 200) {
        setState(() {
          // Quita el evento registrado de ambas listas
          availableEvents.removeWhere((e) => e['id'] == event['id']);
          filterEvents.removeWhere((e) => e['id'] == event['id']);
        });
        showSuccessSnackBar('Te has registrado al evento');
      } else {
        showErrorSnackBar('Error al registrarse al evento');
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

  void showSuccessSnackBar(String message) {
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
          'Lista de eventos',
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
        child: filterEvents.isEmpty
            ? const Center(
                child: Text(
                  'No hay eventos disponibles',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              )
            : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: filterEvents.length,
              itemBuilder: (context, index) {
                final event = filterEvents[index];
                return GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => showEventDialog(
                        event: event,
                        registerEvents: () => registerEvent(event),
                      ),
                    );
                  },
                  child: EventCategoryWidget(
                    category: event['category'] ?? 'Categoría no disponible',
                    imageUrl: event['image_url'] ?? '',
                    title: event['title'] ?? 'Título no disponible',
                    startTime: DateTime.parse(event['start_time']),
                  ),
                );
              },
              ),
      ),
      floatingActionButton: EventlistButtons(
        categories: filterEvent, // Asocia el botón flotante al filtro
      ),
      bottomNavigationBar: const Menu(currentIndex: 0),
    );
  }
}

