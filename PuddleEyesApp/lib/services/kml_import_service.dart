import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:xml/xml.dart';

class KMLImportService {
  static Future<List<Map<String, double>>> importKML() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['kml'],
    );

    if (result == null) {
      return [];
    }

    final file = File(result.files.single.path!);
    final xmlString = await file.readAsString();

    final document = XmlDocument.parse(xmlString);

    final List<Map<String, double>> points = [];

    final coordinates = document.findAllElements("coordinates");

    for (var coord in coordinates) {
      final text = coord.value?.trim() ?? '';
      final parts = text.split(",");

      if (parts.length >= 2) {
        final lon = double.parse(parts[0]);
        final lat = double.parse(parts[1]);

        points.add({"lat": lat, "lon": lon});
      }
    }

    return points;
  }
}
