import 'dart:convert';
import 'esp32_models.dart';

class Esp32Parser {
  static List<ScanPoint> parseScan(String jsonStr) {
    try {
      final List<dynamic> data = jsonDecode(jsonStr);

      return data
        .map((e) => ScanPoint.fromJson(e as Map<String, dynamic>))
        .toList();
    } catch (e) {
      print(" JSON parse error: $e");
      return [];
    }
  }
}