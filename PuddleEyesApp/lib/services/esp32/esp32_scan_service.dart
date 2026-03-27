import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:puddle_eyes_app/services/parser_service.dart';

class Esp32ScanService {
  static const String baseUrl = 'http://192.168.18.25';

  static Future<List<Point3D>> fetchScan() async {
    final response = await http.get(Uri.parse('$baseUrl/scan'));

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch scan: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as List<dynamic>;

    return data.map((e) {
      return Point3D(
        x: (e['x'] as num).toDouble(),
        y: (e['y'] as num).toDouble(),
        z: (e['z'] as num).toDouble(),
      );
    }).toList();
  }

  static Future<Map<String, dynamic>> fetchRaw() async {
    final response = await http.get(Uri.parse('$baseUrl/raw'));

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch raw: ${response.statusCode}');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}