import 'package:flutter/material.dart';

Color rankColor(String rank) {
  if (rank.startsWith('Diamond')) return const Color(0xff60a5fa);
  if (rank.startsWith('Gold')) return const Color(0xfff5c451);
  if (rank.startsWith('Silver')) return const Color(0xffcbd5e1);
  if (rank.startsWith('Master')) return const Color.fromARGB(255, 255, 0, 0);
  // Else return bronze color
  return const Color(0xffb7794b);
}
