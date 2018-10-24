List<String> stringToColor(String str) {
  List<String> _colors = new List(2);
  String _backgroundColor = str != null
      ? _fixLength('#' + (31 * str.hashCode).toRadixString(16).substring(2))
      : "#eee";
  String _foregroundColor =
      _brightnessByColor(_backgroundColor) < 0.5 ? '#000' : '#FFF';
  _colors[0] = _backgroundColor;
  _colors[1] = _foregroundColor;
  return _colors;
}

String _fixLength(String color) {
  if (color.length < 7) {
    return color + '0' * (7 - color.length);
  } else if (color.length > 7) {
    return color.substring(0, 7);
  }
  return color;
}

// Modified from https://gist.github.com/w3core/e3d9b5b6d69a3ba8671cc84714cca8a4
/**
 * Calculate brightness value by RGB or HEX color.
 * @param color (String) The color value in RGB or HEX (for example: #000000 || #000 || rgb(0,0,0) || rgba(0,0,0,0))
 * @returns (Number) The brightness value (dark) 0 ... 255 (light)
 */
double _brightnessByColor(String color) {
  bool isHEX = color.indexOf("#") == 0;
  bool isRGB = color.indexOf("rgb") == 0;
  int r, g, b;
  if (isHEX) {
    RegExp _regExp =
        color.length == 7 ? RegExp(r"(\S{2})") : RegExp(r"(\S{1})");
    List<Match> m = _regExp.allMatches(color.substring(1)).toList();
    if (m.isNotEmpty && m.length >= 3) {
      r = int.parse(m[0].group(0), radix: 16);
      g = int.parse(m[1].group(0), radix: 16);
      b = int.parse(m[2].group(0), radix: 16);
    }
  }
  if (isRGB) {
    RegExp _regExp = RegExp(r"(\d+){3}");
    List<Match> m = _regExp.allMatches(color.substring(1)).toList();
    if (m.isNotEmpty && m.length >= 3) {
      r = int.parse(m[0].group(0));
      g = int.parse(m[1].group(0));
      b = int.parse(m[2].group(0));
    }
  }
  if (r != null) return ((r * 0.299) + (g * 0.587) + (b * 0.114)) / 100;
  return 0.0;
}
