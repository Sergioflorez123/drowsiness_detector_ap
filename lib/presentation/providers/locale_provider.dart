import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final localeProvider =
    StateNotifierProvider<LocaleController, Locale>((ref) {
  return LocaleController();
});

class LocaleController extends StateNotifier<Locale> {
  static const _key = 'app_locale_code';

  LocaleController() : super(const Locale('es')) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_key);
    if (code == 'en') {
      state = const Locale('en');
    } else {
      state = const Locale('es');
    }
  }

  Future<void> setSpanish() => _persist(const Locale('es'));

  Future<void> setEnglish() => _persist(const Locale('en'));

  Future<void> _persist(Locale locale) async {
    state = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, locale.languageCode);
  }
}
