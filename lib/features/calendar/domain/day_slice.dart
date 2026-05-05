import 'package:flutter/material.dart';

class DaySlice {
  const DaySlice(this.name, this.colorValue, this.quantity);
  final String name;
  final int colorValue;
  final int quantity;
  Color get color => Color(colorValue);
}

String dayKey(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
String shortDay(DateTime d) =>
    '${['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][d.weekday - 1]}\n${d.month}/${d.day}';
