import 'package:hive/hive.dart';
part 'obstacle_model.g.dart';

@HiveType(typeId: 0)
class Obstacle extends HiveObject {
  @HiveField(0)
  double lat;
  @HiveField(1)
  double lon;
  @HiveField(2)
  double depth;
  @HiveField(3)
  DateTime timestamp;

  Obstacle({required this.lat, required this.lon, required this.depth, required this.timestamp});
}