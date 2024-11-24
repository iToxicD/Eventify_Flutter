import 'package:flutter/material.dart';

class Tabsevents extends StatelessWidget {
  final List<dynamic> allEvents;
  final List<dynamic> registeredEvents;
  final String role;
  final Function(String) onCategoryFilter;
  final Function(dynamic) onRegister;
  final Function(dynamic)
      onUnregister; // Nuevo callback para desregistrar eventos

  const Tabsevents({
    super.key,
    required this.allEvents,
    required this.registeredEvents,
    required this.role,
    required this.onCategoryFilter,
    required this.onRegister,
    required this.onUnregister, // Nuevo parámetro
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'Disponibles'),
              Tab(text: 'Registrados'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                // Pestaña de eventos disponibles
                ListView.builder(
                  itemCount: allEvents.length,
                  itemBuilder: (context, index) {
                    var event = allEvents[index];
                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      elevation: 4.0,
                      child: ListTile(
                        leading: event['image_url'] != null
                            ? Image.network(
                                event['image_url'],
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              )
                            : const Icon(Icons.event),
                        title: Text(event['title']),
                        subtitle: Text(
                          'Inicio: ${event['start_time']}',
                        ),
                        trailing: ElevatedButton(
                          onPressed: () => onRegister(event),
                          child: const Text('Registrarse'),
                        ),
                      ),
                    );
                  },
                ),
                // Pestaña de eventos registrados
                ListView.builder(
                  itemCount: registeredEvents.length,
                  itemBuilder: (context, index) {
                    var event = registeredEvents[index];
                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      elevation: 4.0,
                      child: ListTile(
                        leading: event['image_url'] != null
                            ? Image.network(
                                event['image_url'],
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              )
                            : const Icon(Icons.event),
                        title: Text(event['title']),
                        subtitle: Text(
                          'Inicio: ${event['start_time']}',
                        ),
                        trailing: ElevatedButton(
                          onPressed: () => onUnregister(event),
                          style: ElevatedButton.styleFrom(
                              // Botón rojo para desregistrarse
                              ),
                          child: const Text(
                            'Borrarse',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
