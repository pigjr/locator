import 'package:flutter/material.dart';

class ExposeLocalizations {
  ExposeLocalizations(this.locale);

  final Locale locale;

  static ExposeLocalizations of(BuildContext context) {
    return Localizations.of<ExposeLocalizations>(context, ExposeLocalizations);
  }

  static Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'title': 'Your Items',
      'signOut': 'Sign Out',
      'searchHint': "Which item are you looking for?",
      'empty': "Whoa, such empty",
    },
    'zh': {
      'title': '物品列表',
      'signOut': '登出',
      'searchHint': "Which item are you looking for?",
      'empty': "Whoa, such empty",
    },
  };

  String get(String key) {
    return _localizedValues[locale.languageCode][key];
  }
}