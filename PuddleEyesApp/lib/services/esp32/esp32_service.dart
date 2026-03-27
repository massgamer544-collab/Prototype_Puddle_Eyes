import 'dart:async';
import 'package:http/http.dart' as http;

import 'esp32_parser.dart';
import 'esp32_models.dart';

class Esp32Service {
  final String baseUrl;

  Esp32Service({this.baseUrl = "http://192.168.4.1"});

  Future<List<ScanPoint>> fetchScan() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/scan"));

      if (response.statusCode == 200) {
        return Esp32Parser.parseScan(response.body);
      } else {
        print("⚠️ ESP32 HTTP error: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("❌ ESP32 fetch error: $e");
      return [];
    }
  }

  /// 🔁 Stream temps réel (polling)
  Stream<List<ScanPoint>> streamScan({
    Duration interval = const Duration(milliseconds: 200),
  }) async* {
    while (true) {
      final data = await fetchScan();
      yield data;
      await Future.delayed(interval);
    }
  }
}