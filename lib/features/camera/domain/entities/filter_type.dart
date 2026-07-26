import 'package:flutter/material.dart';

enum FilterType {
  none,
  blackAndWhite,
  vintage,
  warm,
  cool,
  beauty;

  String get label {
    switch (this) {
      case FilterType.none:
        return 'Normal';
      case FilterType.blackAndWhite:
        return 'B&W';
      case FilterType.vintage:
        return 'Vintage';
      case FilterType.warm:
        return 'Warm';
      case FilterType.cool:
        return 'Cool';
      case FilterType.beauty:
        return 'Beauty';
    }
  }

  /// 4x5 colour matrix consumed by [ColorFilter.matrix].
  List<double> get matrix {
    switch (this) {
      case FilterType.none:
        return const [
          1, 0, 0, 0, 0,
          0, 1, 0, 0, 0,
          0, 0, 1, 0, 0,
          0, 0, 0, 1, 0,
        ];
      case FilterType.blackAndWhite:
        return const [
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0, 0, 0, 1, 0,
        ];
      case FilterType.vintage:
        return const [
          0.9, 0.5, 0.1, 0, -20,
          0.3, 0.8, 0.1, 0, -10,
          0.2, 0.3, 0.5, 0, 10,
          0, 0, 0, 1, 0,
        ];
      case FilterType.warm:
        return const [
          1.15, 0, 0, 0, 15,
          0, 1.05, 0, 0, 5,
          0, 0, 0.85, 0, -10,
          0, 0, 0, 1, 0,
        ];
      case FilterType.cool:
        return const [
          0.85, 0, 0, 0, -10,
          0, 1.0, 0, 0, 0,
          0, 0, 1.2, 0, 15,
          0, 0, 0, 1, 0,
        ];
      case FilterType.beauty:
        return const [
          1.05, 0, 0, 0, 12,
          0, 1.05, 0, 0, 10,
          0, 0, 1.05, 0, 10,
          0, 0, 0, 1, 0,
        ];
    }
  }
}
