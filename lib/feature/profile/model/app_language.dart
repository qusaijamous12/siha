import 'package:flutter/widgets.dart';

enum AppLanguage {
  english('en'),
  arabic('ar');

  const AppLanguage(this.code);

  final String code;
  Locale get locale => Locale(code);
}
