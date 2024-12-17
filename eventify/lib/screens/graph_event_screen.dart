import 'dart:convert';

import 'package:eventify/provider/event_provider.dart';
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
    findEvents();
    findUserData();
    findCategories();
  }

  // Lista de categorías disponibles
  Map<String, String> categories = {};
  List<dynamic> eventData = [];
  List<dynamic> userData = [];
  bool status = true; // Para mostrar un mensaje, si no hay datos

  // Categoria que saldrá por defecto
  String selectCategory = "Technology";

  // Obtiene los eventos creado por el organizador
  Future<void> findEvents() async {
    try {
      var response = await EventProvider.getEventsByOrganizer();
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        setState(() {
          eventData = List<dynamic>.from(data['data']);
          print("Eventos cargados: $eventData");
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

        setState(() {
          // Filtra los eventos segun la categoria
          eventData = List<dynamic>.from(data['data']).where((event) {
            return event['category_id'].toString() == categoryId;
          }).toList();
          print("Eventos filtrados para la categoría $categoryId: $eventData");
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

  // Datos para mostrar en la gráfica
  List<DatosMes?> getData() {
    // Obtener el ID de la categoría seleccionada
    String? categoryId = categories.entries
        .firstWhere((entry) => entry.value == selectCategory,
            orElse: () => MapEntry('', ''))
        .key;

    // Filtrar eventos por el id de la categoría
    List<dynamic> filterData = eventData
        .where((event) => event['category_id'].toString() == categoryId)
        .toList();

    print("Eventos filtrados (${selectCategory}): ${jsonEncode(filterData)}");

    if (filterData.isEmpty) return [];
    return filterData
        .map((event) {
          // Verifica que las claves 'month' y 'registeredEvents' existan
          if (event.containsKey('month') &&
              event.containsKey('registeredEvents')) {
            return DatosMes(event['month'], event['registeredEvents']);
          } else {
            print("Evento sin datos válidos: ${jsonEncode(event)}");
            return null; // Ignora datos inválidos
          }
        })
        .where((element) => element != null)
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
                      findEvents();
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
