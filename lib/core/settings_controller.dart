import 'package:flutter/material.dart';
import 'strings.dart';

class SettingsController extends ChangeNotifier {
  String _locale = 'en';

  String get locale => _locale;

  bool get isRtl => false;

  TextDirection get textDirection => TextDirection.ltr;

  void setLocale(String value) {
    if (_locale == value) return;
    _locale = value;
    notifyListeners();
  }

  String t(String key) => Strings.t(key, _locale);
}
