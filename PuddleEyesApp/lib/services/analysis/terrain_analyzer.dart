import '../esp32/esp32_models.dart';

enum Zone { left, center, right }

class ZoneAnalysis {
  final double avgDepth;
  final bool hasObstacle;
  final double score;

  ZoneAnalysis({
    required this.avgDepth,
    required this.hasObstacle,
    required this.score,
  });
}

class TerrainAnalysisResult {
  final Map<Zone, ZoneAnalysis> zones;
  final Zone? safestZone;
  final String risk;

  TerrainAnalysisResult({
    required this.zones,
    required this.safestZone,
    required this.risk,
  });
}

class TerrainAnalyzer {
  static TerrainAnalysisResult analyze(List<ScanPoint> points) {
    final left = _filter(points, -1.0, -0.33);
    final center = _filter(points, -0.33, 0.33);
    final right = _filter(points, 0.33, 1.0);

    final leftAnalysis = _analyzeZone(left);
    final centerAnalysis = _analyzeZone(center);
    final rightAnalysis = _analyzeZone(right);

    final zones = {
      Zone.left: leftAnalysis,
      Zone.center: centerAnalysis,
      Zone.right: rightAnalysis,
    };

    final safest = _findSafest(zones);
    final risk = _computeRisk(zones);

    return TerrainAnalysisResult(
      zones: zones,
      safestZone: safest,
      risk: risk,
    );
  }

  static List<ScanPoint> _filter(List<ScanPoint> points, double minX, double maxX) {
    return points.where((p) => p.x >= minX && p.x <= maxX).toList();
  }

  static ZoneAnalysis _analyzeZone(List<ScanPoint> pts) {
    if (pts.isEmpty) {
      return ZoneAnalysis(avgDepth: 0, hasObstacle: false, score: 999);
    }

    final avgDepth =
        pts.map((e) => e.z).reduce((a, b) => a + b) / pts.length;

    final hasObstacle = _detectSpike(pts);

    double score = avgDepth;

    if (hasObstacle) {
      score += 1000; // priorité obstacle
    }

    return ZoneAnalysis(
      avgDepth: avgDepth,
      hasObstacle: hasObstacle,
      score: score,
    );
  }

  static bool _detectSpike(List<ScanPoint> pts) {
    if (pts.length < 3) return false;

    final sorted = [...pts]..sort((a, b) => a.x.compareTo(b.x));

    for (int i = 1; i < sorted.length - 1; i++) {
      final left = sorted[i - 1];
      final mid = sorted[i];
      final right = sorted[i + 1];

      final surrounding = (left.z + right.z) / 2;
      final protrusion = surrounding - mid.z;

      if (protrusion > 0.18) {
        return true;
      }
    }

    return false;
  }

  static Zone? _findSafest(Map<Zone, ZoneAnalysis> zones) {
    Zone? best;
    double bestScore = double.infinity;

    zones.forEach((zone, data) {
      if (data.score < bestScore) {
        bestScore = data.score;
        best = zone;
      }
    });

    return best;
  }

  static String _computeRisk(Map<Zone, ZoneAnalysis> zones) {
    final hasDanger =
        zones.values.any((z) => z.hasObstacle || z.avgDepth > 0.35);

    final hasCaution =
        zones.values.any((z) => z.avgDepth > 0.2);

    if (hasDanger) return "DANGER";
    if (hasCaution) return "CAUTION";
    return "SAFE";
  }
}