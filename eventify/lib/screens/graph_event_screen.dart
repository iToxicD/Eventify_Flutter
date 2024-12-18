import 'dart:convert';

import 'package:eventify/provider/event_provider.dart';
import 'package:eventify/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../widgets/menu.dart';

class GraphEventScreen extends StatefulWidget {
  @override
  _GraphEventScreenState createState() => _GraphEventScreenState();
}

class _GraphEventScreenState extends State<GraphEventScreen> {
  @override
  void initState() {
    super.initState();
    initializeData();
  }

  Future<void> initializeData() async {
    await findEvents(); // Asegura que los datos se carguen primero
    await findUserData();
    await findCategories();
    await getEventRegistrationCounts();
    print("eventos id del organizador después de cargar datos: $eventsOfThisOrganizer");
  }

  // Lista de categorías disponibles
  Map<String, String> categories = {};
  List<dynamic> eventData = [];
  List<dynamic> userData = [];
  List<dynamic> eventsOfThisOrganizer = [];
  bool status = true; // Para mostrar un mensaje, si no hay datos

  // Categoria que saldrá por defecto
  String selectCategory = "Technology";

  // Obtiene los eventos creado por el organizador
  Future<void> findEvents() async {
    try {
      var response = await EventProvider.getEventsByOrganizer();
        print("Respuesta del servidor: ${response.body}");
        print("Código de estado: ${response.statusCode}"); 
  
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        setState(() {
          eventData = List<dynamic>.from(data['data']);
          eventsOfThisOrganizer = eventData.map((event) {
            return event['id'];
            }).toList();
            print("Eventos cargados: $eventData");
            print("IDs de eventos: $eventsOfThisOrganizer");
          
        });
      } else {
        throw Exception('Error al cargar los eventos');
      }
    } catch (e) {
      setState(() {
        status = false;
      });
      print("Error al cargar eventos: $e");
    }
  }

  // Filtra los eventos del organizador
  Future<void> findEventsByCategory(String categoryId) async {
    try {
      var response = await EventProvider.getEventsByOrganizer();
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        print("Datos de los eventos: ${jsonEncode(data['data'])}");

        setState(() {
          eventData = List<dynamic>.from(data['data']);
          print("Ave maria: ${eventData}");
          var eventIds = eventData.where((event) {
            // Asegúrate de convertir ambos valores a String para la comparación
            return event['category_name'].toString() == categoryId;
          }).map((event) => event['id'].toString()).toList();

          // Mapa que relacione el category_name con la id de la categoria
          // Imprime las IDs de los eventos filtrados para verificar el resultado
          print("IDs de eventos filtrados para la categoría $categoryId: $eventIds");

          // Si eventIds está vacío, significa que no hubo coincidencias
          if (eventIds.isEmpty) {
            print("No se encontraron eventos para la categoría $categoryId.");
          }
        });
      } else {
        throw Exception('Error al cargar los eventos por categoría');
      }
    } catch (e) {
      setState(() {
        status = false;
      });
      print("Error al cargar eventos por categoría: $e");
    }
  }

  // Obtiene informacion del usuario
  Future<void> findUserData() async {
    try {
      var response = await EventProvider.getEventsByUser();
      if (response.statusCode == 200) {
        setState(() {
          userData = jsonDecode(response.body);
        });
      } else {
        throw Exception('Error al cargar los datos de usuarios');
      }
    } catch (e) {
      print(e);
    }
  }

  // Obtiene las categorias
  Future<void> findCategories() async {
    var response = await EventProvider.getCategories();
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      var categoriesData = List<Map<String, dynamic>>.from(data['data']);
      setState(() {
        // Convierte la lista de mapas en un Map
        categories = {
          for (var category in categoriesData)
            category['id'].toString(): category['name']
        };
        print("Categorías cargadas: $categories");
      });
    } else {
      print('Error al buscar categorias: ${response.body}');
    }
  }


Future<Map<String, int>> getEventRegistrationCounts() async {
  // print("esto hace algo: ${eventData}");
  // Mapa para almacenar los conteos por ID de evento
  Map<String, int> eventRegistrationCounts = {
    for (var eventId in eventsOfThisOrganizer) eventId.toString(): 0
  };
  print("IDs de eventos ola: $eventsOfThisOrganizer");
  try {
    // Obtener la lista de usuarios
    var response = await UserProvider.getUsers();
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);

      // Filtrar usuarios con rol 'u'
      List<dynamic> users = List<dynamic>.from(data['data']);
      var filteredUsers = users.where((user) => user['role'] == 'u');
      print(filteredUsers);

      // Iterar sobre cada usuario con rol 'u'
      for (var user in filteredUsers) {
        print(user);
        String userId = user['id'].toString();

        // Obtener eventos del usuario usando el método `getEventsByUser`
        var userEventsResponse = await EventProvider.getEventsByUserId(userId);
        
        if (userEventsResponse.statusCode == 200) {
          var userEventsData = jsonDecode(userEventsResponse.body);
          print(userEventsData);

          // IDs de los eventos a los que está registrado el usuario
          List<String> userEventIds = List<dynamic>.from(userEventsData['data'])
              .map((event) => event['id'].toString())
              .toList();
          print("Lista de eventos del usuario: ${userEventIds}");

          // Comparar con `eventsOfThisOrganizer` y actualizar el mapa
          for (var eventId in userEventIds) {
            if (eventRegistrationCounts.containsKey(eventId)) {
              eventRegistrationCounts[eventId] =
                  eventRegistrationCounts[eventId]! + 1;
            }
          }
        }
      }
    }
  } catch (e) {
    print("Error al procesar los registros de eventos: $e");
  }
  print("Resultado: ${eventRegistrationCounts}");
  return eventRegistrationCounts;
}

  List<DatosMes> getData() {
    // Obtener el ID de la categoría seleccionada
    String? categoryId = categories.entries
        .firstWhere((entry) => entry.value == selectCategory,
            orElse: () => MapEntry('', ''))
        .key;
    print("Categoría seleccionada ID: $categoryId");
    // Filtrar eventos por el ID de la categoría
    List<dynamic> filterData = eventData
        .where((event) => event['category_id'].toString() == categoryId)
        .toList();

    print("Eventos filtrados (${selectCategory}): ${jsonEncode(filterData)}");

    // Mapea los datos filtrados, ignorando los valores inválidos
    return filterData
        .where((event) =>
            event.containsKey('month') && event.containsKey('registeredEvents'))
        .map((event) => DatosMes(event['month'], event['registeredEvents']))
        .toList();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Gráficas',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xff620091),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Desplegable para la categoría
            Text(
              "Selecciona una categoría:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            categories.isEmpty
                ? Center(child: CircularProgressIndicator())
                : DropdownButton<String>(
                    value: categories.containsKey(selectCategory)
                      ? selectCategory
                      : categories.keys.first,
                    items: categories.entries.map((entry) {
                      return DropdownMenuItem<String>(
                        value: entry.key, // id de la categoría
                        child: Text(entry.value), // Nombre de la categoría
                      );
                    }).toList(),
                    onChanged: (String? nuevaCategoriaId) {
                      setState(() {
                        selectCategory = nuevaCategoriaId!;
                      });

                      // Actualiza los datos
                      
                      findEventsByCategory(selectCategory);
                    },
                  ),

            SizedBox(height: 16),

            // Gráfica
            Expanded(
              child: SfCartesianChart(
                title: ChartTitle(text: 'Registros en los últimos 4 meses'),
                primaryXAxis: CategoryAxis(
                  title: AxisTitle(text: 'Meses'),
                ),
                primaryYAxis: NumericAxis(
                  title: AxisTitle(text: 'Registros'),
                ),
                series: <ChartSeries>[
                  ColumnSeries<DatosMes, String>(
                    dataSource: getData(),
                    xValueMapper: (DatosMes dato, _) => dato.mes,
                    yValueMapper: (DatosMes dato, _) => dato.valor,
                    name: selectCategory,
                    color: Color(0xff620091),
                    dataLabelSettings: DataLabelSettings(isVisible: true),
                  )
                ],
                tooltipBehavior: TooltipBehavior(enable: true),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const Menu(currentIndex: 0),
    );
  }
}

// Clase para estructurar los datos de la gráfica
class DatosMes {
  final String mes;
  final int valor;

  DatosMes(this.mes, this.valor);
}
