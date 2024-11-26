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
  List<dynamic> events = [];
  List<dynamic> filterEvents = [];
  String allCategories = "all";

  @override
  void initState() {
    super.initState();
    fetchAvailableEvents();
  }

  Future<void> fetchAvailableEvents() async {
    try {
      var response = await EventProvider.getEvents();

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        List<dynamic> events = jsonResponse['data'];

        setState(() {
          availableEvents = events;
        });
      } else {
        showErrorSnackBar('Error al cargar eventos disponibles');
      }
    } catch (e) {
      showErrorSnackBar('Error de conexión');
    }
  }

  // Filtra los eventos según la categoría seleccionada
  void filterEvent(String category) {
    setState(() {
      allCategories = category;
      if (category == 'All') {
        filterEvents =
            availableEvents; // Si se selecciona "All", mostramos todos los eventos
      } else {
        filterEvents = availableEvents.where((event) {
          return event['category'] == category;
        }).toList();
      }
    });
  }

  Future<void> registerEvent(dynamic event) async {
    try {
      var response = await EventProvider.register(event['id']);

      if (response.statusCode == 200) {
        setState(() {
          availableEvents.remove(event);
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
          content: Text(message, style: const TextStyle(color: Colors.white))),
    );
  }

  void showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(message, style: const TextStyle(color: Colors.white))),
    );
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
    });
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
        child: availableEvents.isEmpty
            ? const Center(
                child: Text(
                  'No hay eventos disponibles',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: availableEvents.length,
                itemBuilder: (context, index) {
                  var event = availableEvents[index];
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
        categories: eventCategories,
      ),
      bottomNavigationBar: const Menu(currentIndex: 0),
    );
  }
}
