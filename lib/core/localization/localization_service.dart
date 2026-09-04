import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:yeni_oyun_sablon/core/localization/app_language.dart';

/// Oyun İçi Yerelleştirme ve Çok Dilli Çeviri Yöneticisi
class LocalizationService {
  static LocalizationService? _instance;
  static LocalizationService get instance => _instance ??= LocalizationService._();

  LocalizationService._();

  AppLanguage _currentLanguage = AppLanguage.tr;
  Map<String, String> _localizedStrings = {};

  AppLanguage get currentLanguage => _currentLanguage;

  /// Hive'dan kayıtlı dili okuyarak ve ilgili JSON dosyasını yükleyerek servisi başlatır
  Future<void> init() async {
    final box = Hive.isBoxOpen('settingsBox')
        ? Hive.box('settingsBox')
        : await Hive.openBox('settingsBox');

    final savedCode = box.get('selectedLanguageCode', defaultValue: 'tr') as String;
    await setLanguage(AppLanguage.fromCode(savedCode));
  }

  /// Aktif dili değiştirir, yeni JSON dosyasını yükler ve Hive'a kaydeder
  Future<void> setLanguage(AppLanguage language) async {
    _currentLanguage = language;

    try {
      final jsonString = await rootBundle.loadString('assets/lang/${language.code}.json');
      final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
      _localizedStrings = jsonMap.map((key, value) => MapEntry(key, value.toString()));
    } catch (e) {
      _localizedStrings = {};
    }

    final box = Hive.box('settingsBox');
    await box.put('selectedLanguageCode', language.code);
  }

  /// Anahtar kelimeye karşılık gelen çeviriyi döndürür
  String t(String key) {
    return _localizedStrings[key] ?? key;
  }
}

/// Kolay erişim için global çeviri fonksiyonu
String tr(String key) => LocalizationService.instance.t(key);

/// Riverpod Dil Durumu Yöneticisi
class LanguageNotifier extends StateNotifier<AppLanguage> {
  LanguageNotifier() : super(LocalizationService.instance.currentLanguage);

  Future<void> changeLanguage(AppLanguage language) async {
    await LocalizationService.instance.setLanguage(language);
    state = language;
  }
}

/// Aktif dili izleyen Riverpod Provider'ı
final languageProvider = StateNotifierProvider<LanguageNotifier, AppLanguage>((ref) {
  return LanguageNotifier();
});
