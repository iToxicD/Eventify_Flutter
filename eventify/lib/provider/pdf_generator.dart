import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

class PdfGenerator {
  Future<File> generatePdf(List<Map<String, String>> eventos) async {
    final pdf = pw.Document();

    // Cargar todas las imágenes previamente
    final List<pw.MemoryImage?> imagenes = await Future.wait(
      eventos.map((evento) async {
        if (evento['imagen'] != null && evento['imagen']!.isNotEmpty) {
          try {
            return await _loadImage(evento['imagen']!);
          } catch (_) {
            return null; // Imagen no cargada
          }
        }
        return null;
      }).toList(),
    );

    // Crear las páginas del PDF
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: List.generate(eventos.length, (index) {
              final evento = eventos[index];
              final imagen = imagenes[index];

              return pw.Column(
                children: [
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // Imagen
                      pw.Expanded(
                        flex: 1,
                        child: imagen != null
                            ? pw.Image(imagen, width: 100, height: 100) // Tamaño de imagen aumentado
                            : pw.Text("Sin imagen"),
                      ),
                      pw.SizedBox(width: 10), // Espaciado entre columnas
                      // Título y fecha
                      pw.Expanded(
                        flex: 3,
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              evento['titulo'] != null && evento['titulo']!.isNotEmpty
                                  ? evento['titulo']!
                                  : 'Sin título',
                            ),
                            pw.Text(
                              evento['fecha'] ?? 'Sin fecha',
                              style: const pw.TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 20), // Espaciado entre filas de eventos
                ],
              );
            }),
          );
        },
      ),
    );

    // Verificar permisos de almacenamiento
    await _requestStoragePermission();

    // Obtener la carpeta de descargas (para Android 10 y versiones superiores)
    final directory = await _getDownloadsDirectory();
    if (directory == null) {
      throw Exception("No se pudo encontrar la carpeta de descargas.");
    }

    // Crear el archivo PDF
    final file = File("${directory.path}/eventos.pdf");
    await file.writeAsBytes(await pdf.save());

    return file;
  }

  Future<void> printPdf(File pdfFile) async {
    await Printing.layoutPdf(onLayout: (format) async => pdfFile.readAsBytesSync());
  }

  // Función para descargar y cargar la imagen en el PDF
  Future<pw.MemoryImage> _loadImage(String imageUrl) async {
    final response = await http.get(Uri.parse(imageUrl));
    if (response.statusCode == 200) {
      return pw.MemoryImage(response.bodyBytes);
    } else {
      throw Exception("Error al cargar la imagen");
    }
  }

  // Solicitar permisos de almacenamiento en Android
  Future<void> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      // Permisos para Android 10 y versiones superiores
      if (await Permission.storage.isGranted) {
        return; // El permiso ya está concedido
      } else {
        // Solicitar el permiso
        await Permission.storage.request();
      }
    }
  }

  // Obtener la carpeta de descargas para Android
  Future<Directory?> _getDownloadsDirectory() async {
    if (Platform.isAndroid) {
      // Para Android 10+ usa el Storage Access Framework (SAF)
      if (Directory('/storage/emulated/0/Download').existsSync()) {
        return Directory('/storage/emulated/0/Download');
      }
    }
    return null; // Si no se puede encontrar la carpeta de descargas
  }
}
