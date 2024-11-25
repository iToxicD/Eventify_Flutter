import 'dart:convert';
import 'package:eventify/widgets/eventlist_buttons.dart';
import 'package:eventify/widgets/menu.dart';
import 'package:eventify/provider/event_provider.dart';
import 'package:eventify/widgets/event_category_widget.dart';
import 'package:eventify/widgets/showDialog.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EventListScreen extends StatefulWidget {
  const EventListScreen({super.key});

  @override
  _EventListScreenState createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  List<dynamic> allEvents = [];
  List<dynamic> registeredEvents = [];
  String role = '';

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  Future<void> initializeData() async {
    await fetchRole();
    await fetchRegisteredEvents();
    await fetchAvailableEvents();
  }

  Future<void> fetchRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedRole = prefs.getString('role');
    setState(() {
      role = savedRole ?? '';
    });
  }

  Future<void> fetchAvailableEvents() async {
    var response = await EventProvider.getEvents();

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      List<dynamic> events = jsonResponse['data'];

      setState(() {
        allEvents = events.where((event) {
          return !registeredEvents
              .any((regEvent) => regEvent['id'] == event['id']);
        }).toList();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al cargar eventos disponibles')),
      );
    }
  }

  Future<void> fetchRegisteredEvents() async {
    var response = await EventProvider.getEventsByUser();

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      setState(() {
        registeredEvents = jsonResponse['data'];
      });
      print('evento registrado: $registeredEvents');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al cargar eventos registrados')),
      );
    }
  }

  Future<void> registerEvent(dynamic event) async {
    var response = await EventProvider.register(event['id']);

    if (response.statusCode == 200) {
      setState(() {
        allEvents.remove(event);
        registeredEvents.add(event);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Te has registrado al evento')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al registrarse al evento')),
      );
    }
  }

  Future<void> unregisterEvent(dynamic event) async {
    var response = await EventProvider.unregister(event['id']);

    if (response.statusCode == 200) {
      setState(() {
        registeredEvents.remove(event);
        allEvents.add(event);
        allEvents.sort((a, b) {
          DateTime dateA = DateTime.parse(a['start_time']);
          DateTime dateB = DateTime.parse(b['start_time']);
          return dateA.compareTo(dateB);
        });
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Te has borrado del evento')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al cancelar el registro')),
      );
    }
  }

  void eventCategories(String category) {
    setState(() {
      allEvents = category.isEmpty
          ? allEvents
          : allEvents.where((event) => event['category'] == category).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Lista de Eventos',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xff620091),
        shadowColor: Colors.grey[700],
      ),
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
        child: DefaultTabController(
          length: 2,
          child: Column(
            children: [
              const TabBar(
                tabs: [
                  Tab(text: 'Disponibles'),
                  Tab(text: 'Registrados'),
                ],
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey,
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    // Eventos disponibles
                    allEvents.isEmpty
                        ? const Center(
                            child: Text(
                              'No hay eventos disponibles',
                              style: TextStyle(color: Colors.white),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(8.0),
                            itemCount: allEvents.length,
                            itemBuilder: (context, index) {
                              var event = allEvents[index];
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
                                  category:
                                      event['category'] ?? 'Categoría no disponible',
                                  imageUrl: event['image_url'] ?? '',
                                  title: event['title'] ?? 'Título no disponible',
                                  startTime: DateTime.parse(event['start_time']),
                                ),
                              );
                            },
                          ),
                    // Eventos registrados
                    registeredEvents.isEmpty
                        ? const Center(
                            child: Text(
                              'No tienes eventos registrados',
                              style: TextStyle(color: Colors.white),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(8.0),
                            itemCount: registeredEvents.length,
                            itemBuilder: (context, index) {
                              var event = registeredEvents[index];
                              return GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => showEventDialog(
                                      event: event,
                                      unRegisterEvents: () =>
                                          unregisterEvent(event),
                                    ),
                                  );
                                },
                                child: EventCategoryWidget(
                                  category:
                                      event['category'] ?? 'Categoría no disponible',
                                  imageUrl: event['image_url'] ?? '',
                                  title: event['title'] ?? 'Título no disponible',
                                  startTime: DateTime.parse(event['start_time']),
                                ),
                              );
                            },
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const Menu(currentIndex: 2),
    );
  }
}
