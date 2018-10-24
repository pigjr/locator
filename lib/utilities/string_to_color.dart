import 'package:flutter/material.dart';

List<Color> stringToColor(String str) {
  List<Color> _colors = new List(2);
  Color _backgroundColor = str != null ? Color(int.parse(
      'FF' + (31 * str.hashCode).toRadixString(16).substring(2),
      radix: 16)) : Colors.white;
  Color _foregroundColor =
      _backgroundColor.computeLuminance() < 0.5 ? Colors.white : Colors.black;
  _colors[0] = _backgroundColor;
  _colors[1] = _foregroundColor;
  return _colors;
}
