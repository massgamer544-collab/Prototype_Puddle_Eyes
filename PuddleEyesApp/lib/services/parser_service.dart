import 'dart:convert';

class Point3D {
  final double x;
  final double y;
  final double z;

  Point3D({required this.x, required this.y, required this.z});
}

class ParserService {
  static List<Point3D> parseJSONPoints(String jsonString) {
    List<Point3D> list = [];
    try {
      final data = json.decode(jsonString);
      for (var item in data) {
        list.add(Point3D(x: item['x'], y: item['y'], z: item['z']));
      }
    } catch (e) {
      print("Parsing error : $e");
    }
    return list;
  }
}
