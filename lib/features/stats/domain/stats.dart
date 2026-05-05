import 'package:flutter/material.dart';

class Stat {
  const Stat({
    required this.id,
    required this.name,
    required this.iconKey,
    required this.colorValue,
    required this.imageAsset,
    required this.tracked,
    required this.total,
    required this.last,
  });

  final int id;
  final String name;
  final String iconKey;
  final int colorValue;
  final String imageAsset;
  final bool tracked;
  final int total;
  final DateTime? last;

  Color get color => Color(colorValue);
}
