import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:puddle_eyes_app/services/parser_service.dart';
import 'sonar_simulator.dart';
import 'esp32/esp32_scan_service.dart';

class BluetoothService extends ChangeNotifier {
  List<Point3D> points = [];
  final List<List<Point3D>> history = [];

  StreamSubscription<List<Point3D>>? _simSub;
  Timer? _liveTimer;

  bool isLive = false;
  String sourceLabel = 'SIMULATION';
  double scanQuality = 0.0;

  void _updatePoints(List<Point3D> newPoints) {
    points = List.from(newPoints);
    history.add(List.from(newPoints));

    if (history.length > 50) {
      history.removeAt(0);
    }

    _recalculateScanQuality();
    notifyListeners();
  }

  void _recalculateScanQuality() {
    if (points.isEmpty) {
      scanQuality = 0.0;
      return;
    }

    if (points.length <= 3) {
      scanQuality = 0.45;
    } else if (points.length <= 5) {
      scanQuality = 0.60;
    } else if (points.length <= 9) {
      scanQuality = 0.72;
    } else {
      scanQuality = 0.82;
    }

    final delta = (leftDepth - rightDepth).abs();

    if (delta > 0.5) {
      scanQuality -= 0.15;
    } else if (delta > 0.25) {
      scanQuality -= 0.08;
    }

    if (isLive) {
      scanQuality += 0.08;
    }

    scanQuality = scanQuality.clamp(0.0, 1.0);
  }

  void stopAllStreams() {
    _simSub?.cancel();
    _simSub = null;

    _liveTimer?.cancel();
    _liveTimer = null;
  }

  void startSimulationFlat() {
    stopAllStreams();
    isLive = false;
    sourceLabel = 'SIMULATION';
    _simSub = SonarSimulator.flatGround().listen(_updatePoints);
  }

  void startSimulationMudHole() {
    stopAllStreams();
    isLive = false;
    sourceLabel = 'SIMULATION';
    _simSub = SonarSimulator.mudHoleCenter().listen(_updatePoints);
  }

  void startSimulationLeftSafePath() {
    stopAllStreams();
    isLive = false;
    sourceLabel = 'SIMULATION';
    _simSub = SonarSimulator.leftSafePath().listen(_updatePoints);
  }

  void startSimulationRightSafePath() {
    stopAllStreams();
    isLive = false;
    sourceLabel = 'SIMULATION';
    _simSub = SonarSimulator.rightSafePath().listen(_updatePoints);
  }

  void startSimulationDeepWideHole() {
    stopAllStreams();
    isLive = false;
    sourceLabel = 'SIMULATION';
    _simSub = SonarSimulator.deepWideHole().listen(_updatePoints);
  }

  void startSimulationUltraDetailedHole() {
    stopAllStreams();
    isLive = false;
    sourceLabel = 'SIMULATION';
    _simSub = SonarSimulator.ultraDetailedHole().listen(_updatePoints);
  }

  void startSimulationHoleWithStick() {
    stopAllStreams();
    isLive = false;
    sourceLabel = 'SIMULATION';
    _simSub = SonarSimulator.holeWithStick().listen(_updatePoints);
  }

  void startSimulationDualSensorRightDeep() {
    stopAllStreams();
    isLive = false;
    sourceLabel = 'SIMULATION';
    _simSub = SonarSimulator.dualSensorRightDeep().listen(_updatePoints);
  }

  void startSimulationDualSensorLeftDeep() {
    stopAllStreams();
    isLive = false;
    sourceLabel = 'SIMULATION';
    _simSub = SonarSimulator.dualSensorLeftDeep().listen(_updatePoints);
  }

  void startSimulationDualSensorBalancedCaution() {
    stopAllStreams();
    isLive = false;
    sourceLabel = 'SIMULATION';
    _simSub = SonarSimulator.dualSensorBalancedCaution().listen(_updatePoints);
  }

  void startSimulationDualSensorObstacleRight() {
    stopAllStreams();
    isLive = false;
    sourceLabel = 'SIMULATION';
    _simSub = SonarSimulator.dualSensorObstacleRight().listen(_updatePoints);
  }

  void startLiveHttpScan() {
    stopAllStreams();
    isLive = true;
    sourceLabel = 'LIVE SENSOR';

    _liveTimer = Timer.periodic(const Duration(milliseconds: 700), (_) async {
      try {
        final scan = await Esp32ScanService.fetchScan();
        _updatePoints(scan);
      } catch (e) {
        debugPrint('Live scan error: $e');
      }
    });
  }

  Future<Map<String, dynamic>?> fetchLiveRaw() async {
    try {
      return await Esp32ScanService.fetchRaw();
    } catch (e) {
      debugPrint('Raw fetch error: $e');
      return null;
    }
  }

  double get leftDepth {
    if (points.isEmpty) return 0.0;
    final leftPoints = points.where((p) => p.x < -0.15).toList();
    if (leftPoints.isEmpty) return 0.0;
    return leftPoints.map((p) => p.z).reduce((a, b) => a > b ? a : b);
  }

  double get centerDepth {
    if (points.isEmpty) return 0.0;
    final centerPoints =
        points.where((p) => p.x >= -0.15 && p.x <= 0.15).toList();
    if (centerPoints.isEmpty) return 0.0;
    return centerPoints.map((p) => p.z).reduce((a, b) => a > b ? a : b);
  }

  double get rightDepth {
    if (points.isEmpty) return 0.0;
    final rightPoints = points.where((p) => p.x > 0.15).toList();
    if (rightPoints.isEmpty) return 0.0;
    return rightPoints.map((p) => p.z).reduce((a, b) => a > b ? a : b);
  }

  bool _hasSpikeInRange(double minX, double maxX) {
    if (points.length < 3) return false;

    final sorted = [...points]..sort((a, b) => a.x.compareTo(b.x));

    for (int i = 1; i < sorted.length - 1; i++) {
      final left = sorted[i - 1];
      final mid = sorted[i];
      final right = sorted[i + 1];

      if (mid.x < minX || mid.x > maxX) continue;

      final surroundingDepth = (left.z + right.z) / 2.0;
      final protrusion = surroundingDepth - mid.z;

      if (protrusion > 0.18) {
        return true;
      }
    }

    return false;
  }

  bool get hasLeftObstacle => _hasSpikeInRange(-1.0, -0.15);
  bool get hasCenterObstacle => _hasSpikeInRange(-0.15, 0.15);
  bool get hasRightObstacle => _hasSpikeInRange(0.15, 1.0);

  double get leftHazardScore {
    double score = leftDepth;

    if (hasLeftObstacle) {
      score += 0.65;
    }

    if (leftDepth > 0.45) {
      score += 0.15;
    }

    return score;
  }

  double get centerHazardScore {
    double score = centerDepth;

    if (hasCenterObstacle) {
      score += 1.00;
    }

    if (centerDepth > 0.45) {
      score += 0.20;
    }

    return score;
  }

  double get rightHazardScore {
    double score = rightDepth;

    if (hasRightObstacle) {
      score += 0.65;
    }

    if (rightDepth > 0.45) {
      score += 0.15;
    }

    return score;
  }

  double get maxDepth {
    if (points.isEmpty) return 0.0;
    return points.map((p) => p.z).reduce((a, b) => a > b ? a : b);
  }

  bool get hasAnyObstacle =>
      hasLeftObstacle || hasCenterObstacle || hasRightObstacle;

  String get saferSide {
    if (points.isEmpty) return 'UNKNOWN';

    final left = leftHazardScore;
    final center = centerHazardScore;
    final right = rightHazardScore;

    final leftBad = left > 0.70;
    final centerBad = center > 0.70;
    final rightBad = right > 0.70;

    if (hasCenterObstacle) {
      if (!leftBad && !rightBad) {
        return left <= right ? 'LEFT' : 'RIGHT';
      }
      if (!leftBad) return 'LEFT';
      if (!rightBad) return 'RIGHT';
      return 'NONE';
    }

    if (leftBad && centerBad && rightBad) {
      return 'NONE';
    }

    if (!hasCenterObstacle &&
        (left - right).abs() < 0.08 &&
        center < left &&
        center < right &&
        !centerBad) {
      return 'CENTER';
    }

    if (leftBad && !rightBad) return 'RIGHT';
    if (rightBad && !leftBad) return 'LEFT';
    if (!leftBad && !rightBad) return left <= right ? 'LEFT' : 'RIGHT';

    if (!centerBad && !hasCenterObstacle) return 'CENTER';

    return 'NONE';
  }

  String get riskLabel {
    final worst = [
      leftHazardScore,
      centerHazardScore,
      rightHazardScore,
    ].reduce((a, b) => a > b ? a : b);

    if (hasAnyObstacle && worst > 0.50) return 'DANGER';
    if (worst > 0.45) return 'DANGER';
    if (worst > 0.22) return 'CAUTION';
    return 'SAFE';
  }

  String get scanQualityLabel {
    if (scanQuality < 0.4) return 'LOW';
    if (scanQuality < 0.7) return 'MEDIUM';
    return 'HIGH';
  }

  @override
  void dispose() {
    stopAllStreams();
    super.dispose();
  }
}