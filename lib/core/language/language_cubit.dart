import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageCubit extends Cubit<Locale> {
  static const String _languageCodeKey = 'language_code';

  LanguageCubit() : super(const Locale('en')) {
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString(_languageCodeKey);

      if (languageCode != null) {
        emit(Locale(languageCode));
      }
    } catch (e) {
      // Hata durumunda varsayılan dil (İngilizce) kullanılır
      print('Dil yüklenirken hata oluştu: $e');
    }
  }

  Future<void> changeLanguage(String languageCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageCodeKey, languageCode);
      emit(Locale(languageCode));
    } catch (e) {
      print('Dil değiştirilirken hata oluştu: $e');
    }
  }
}
