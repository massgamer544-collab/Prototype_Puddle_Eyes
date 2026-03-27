class ScanPoint {
  final double x;
  final double y;
  final double z;

  ScanPoint({
    required this.x,
    required this.y,
    required this.z,
  });

  factory ScanPoint.fromJson(Map<String, dynamic> json) {
    return ScanPoint(
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      z: (json['z'] as num).toDouble(),
    );
  }
}