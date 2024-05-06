import 'package:flutter/widgets.dart';

class Weather {
  Weather._();

  static const _kFontFam = 'Weather';

  static const IconData sun = IconData(0xe800, fontFamily: _kFontFam);
  static const IconData cloud = IconData(0xe801, fontFamily: _kFontFam);
  static const IconData snow = IconData(0xe802, fontFamily: _kFontFam);
  static const IconData drizzle = IconData(0xe803, fontFamily: _kFontFam);
}
