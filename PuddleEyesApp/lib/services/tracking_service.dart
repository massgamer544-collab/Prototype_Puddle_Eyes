import 'package:hive/hive.dart';
import 'package:geolocator/geolocator.dart';
import 'obstacle_model.dart';

class TrackingService {
  static late Box<Obstacle> obstacleBox;

  static Future<void> init() async {
    Hive.registerAdapter(ObstacleAdapter());
    obstacleBox = await Hive.openBox<Obstacle>('obstacles');
  }

  static Future<void> recordObstacle(double depth) async {
    if (depth < 0.2) return; // seuil minimal pour considérer trou

    Position pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    Obstacle obs = Obstacle(lat: pos.latitude, lon: pos.longitude, depth: depth, timestamp: DateTime.now());
    await obstacleBox.add(obs);
  }

  static List<Obstacle> getAllObstacles() => obstacleBox.values.toList();
}