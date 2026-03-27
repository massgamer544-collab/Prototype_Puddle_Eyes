import 'dart:async';
import 'package:puddle_eyes_app/services/parser_service.dart';

class SonarSimulator {
  static Stream<List<Point3D>> flatGround() async* {
    while (true) {
      await Future.delayed(const Duration(milliseconds: 400));
      yield [
        Point3D(x: -0.70, y: 1.0, z: 0.10),
        Point3D(x:  0.00, y: 1.0, z: 0.10),
        Point3D(x:  0.70, y: 1.0, z: 0.10),
      ];
    }
  }

  static Stream<List<Point3D>> mudHoleCenter() async* {
    while (true) {
      await Future.delayed(const Duration(milliseconds: 400));
      yield [
        Point3D(x: -0.70, y: 1.0, z: 0.18),
        Point3D(x:  0.00, y: 1.0, z: 0.56),
        Point3D(x:  0.70, y: 1.0, z: 0.20),
      ];
    }
  }

  static Stream<List<Point3D>> leftSafePath() async* {
    while (true) {
      await Future.delayed(const Duration(milliseconds: 400));
      yield [
        Point3D(x: -0.70, y: 1.0, z: 0.14), // safer
        Point3D(x:  0.00, y: 1.0, z: 0.34),
        Point3D(x:  0.70, y: 1.0, z: 0.58), // deeper
      ];
    }
  }

  static Stream<List<Point3D>> rightSafePath() async* {
    while (true) {
      await Future.delayed(const Duration(milliseconds: 400));
      yield [
        Point3D(x: -0.70, y: 1.0, z: 0.58), // deeper
        Point3D(x:  0.00, y: 1.0, z: 0.34),
        Point3D(x:  0.70, y: 1.0, z: 0.14), // safer
      ];
    }
  }

  static Stream<List<Point3D>> deepWideHole() async* {
    while (true) {
      await Future.delayed(const Duration(milliseconds: 400));
      yield [
        Point3D(x: -0.70, y: 1.0, z: 0.30),
        Point3D(x:  0.00, y: 1.0, z: 0.72),
        Point3D(x:  0.70, y: 1.0, z: 0.32),
      ];
    }
  }

  static Stream<List<Point3D>> ultraDetailedHole() async* {
    while (true) {
      await Future.delayed(const Duration(milliseconds: 350));
      yield [
        Point3D(x: -1.00, y: 1.0, z: 0.12),
        Point3D(x: -0.80, y: 1.0, z: 0.15),
        Point3D(x: -0.60, y: 1.0, z: 0.22),
        Point3D(x: -0.40, y: 1.0, z: 0.34),
        Point3D(x: -0.20, y: 1.0, z: 0.48),
        Point3D(x:  0.00, y: 1.0, z: 0.62),
        Point3D(x:  0.20, y: 1.0, z: 0.50),
        Point3D(x:  0.40, y: 1.0, z: 0.36),
        Point3D(x:  0.60, y: 1.0, z: 0.24),
        Point3D(x:  0.80, y: 1.0, z: 0.16),
        Point3D(x:  1.00, y: 1.0, z: 0.12),
      ];
    }
  }

  static Stream<List<Point3D>> holeWithStick() async* {
    while (true) {
      await Future.delayed(const Duration(milliseconds: 350));
      yield [
        Point3D(x: -1.00, y: 1.0, z: 0.12),
        Point3D(x: -0.80, y: 1.0, z: 0.17),
        Point3D(x: -0.60, y: 1.0, z: 0.26),
        Point3D(x: -0.40, y: 1.0, z: 0.42),
        Point3D(x: -0.20, y: 1.0, z: 0.58),
        Point3D(x:  0.00, y: 1.0, z: 0.06), // sharp protruding stick
        Point3D(x:  0.20, y: 1.0, z: 0.60),
        Point3D(x:  0.40, y: 1.0, z: 0.44),
        Point3D(x:  0.60, y: 1.0, z: 0.27),
        Point3D(x:  0.80, y: 1.0, z: 0.17),
        Point3D(x:  1.00, y: 1.0, z: 0.12),
      ];
    }
  }

  static Stream<List<Point3D>> dualSensorRightDeep() async* {
    while (true) {
      await Future.delayed(const Duration(milliseconds: 400));
      yield [
        Point3D(x: -0.70, y: 1.0, z: 0.16),
        Point3D(x:  0.00, y: 1.0, z: 0.30),
        Point3D(x:  0.70, y: 1.0, z: 0.62),
      ];
    }
  }

  static Stream<List<Point3D>> dualSensorLeftDeep() async* {
    while (true) {
      await Future.delayed(const Duration(milliseconds: 400));
      yield [
        Point3D(x: -0.70, y: 1.0, z: 0.62),
        Point3D(x:  0.00, y: 1.0, z: 0.30),
        Point3D(x:  0.70, y: 1.0, z: 0.16),
      ];
    }
  }

  static Stream<List<Point3D>> dualSensorBalancedCaution() async* {
    while (true) {
      await Future.delayed(const Duration(milliseconds: 400));
      yield [
        Point3D(x: -0.70, y: 1.0, z: 0.22),
        Point3D(x:  0.00, y: 1.0, z: 0.28),
        Point3D(x:  0.70, y: 1.0, z: 0.24),
      ];
    }
  }

  static Stream<List<Point3D>> dualSensorObstacleRight() async* {
    while (true) {
      await Future.delayed(const Duration(milliseconds: 350));
      yield [
        Point3D(x: -0.70, y: 1.0, z: 0.16),
        Point3D(x:  0.00, y: 1.0, z: 0.24),
        Point3D(x:  0.55, y: 1.0, z: 0.12), // raised object / spike area
        Point3D(x:  0.70, y: 1.0, z: 0.46),
      ];
    }
  }
}