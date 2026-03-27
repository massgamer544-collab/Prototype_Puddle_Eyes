import 'package:flutter/material.dart';
import '../services/esp32/esp32_models.dart';

class ScanState extends ChangeNotifier {
  List<ScanPoint> points = [];

  void update(List<ScanPoint> newPoints) {
    points = newPoints;
    notifyListeners();
  }

  bool get hasData => points.isNotEmpty;
}