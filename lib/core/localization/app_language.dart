/// Desteklenen Oyun Dilleri
enum AppLanguage {
  tr(code: 'tr', name: 'Türkçe', flag: '🇹🇷'),
  en(code: 'en', name: 'English', flag: '🇬🇧'),
  ru(code: 'ru', name: 'Русский', flag: '🇷🇺'),
  es(code: 'es', name: 'Español', flag: '🇪🇸');

  final String code;
  final String name;
  final String flag;

  const AppLanguage({
    required this.code,
    required this.name,
    required this.flag,
  });

  /// Dil koduna göre enum nesnesini döndürür (Varsayılan: Türkçe)
  static AppLanguage fromCode(String? code) {
    if (code == null) return AppLanguage.tr;
    return AppLanguage.values.firstWhere(
      (lang) => lang.code.toLowerCase() == code.toLowerCase(),
      orElse: () => AppLanguage.tr,
    );
  }
}
