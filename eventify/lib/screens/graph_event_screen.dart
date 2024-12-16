import 'package:eventify/widgets/eventlist_buttons.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../widgets/menu.dart';

class GraphEventScreen extends StatefulWidget {
  @override
  _GraphEventScreenState createState() => _GraphEventScreenState();
}

class _GraphEventScreenState extends State<GraphEventScreen> {
  // Lista de categorías disponibles
  final List<String> category = ["Deportes", "Tecnología", "Música"];

  // Categoria que saldrá por defecto
  String selectCategory = "Deportes";

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
            DropdownButton<String>(
              value: selectCategory,
              items: category.map((String categoria) {
                return DropdownMenuItem<String>(
                  value: categoria,
                  child: Text(categoria),
                );
              }).toList(),
              onChanged: (String? nuevaCategoria) {
                setState(() {
                  selectCategory = nuevaCategoria!;
                });
              },
            ),
            SizedBox(height: 16),

            // Gráfica vacía
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
                    dataSource: [], // No hay datos
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
