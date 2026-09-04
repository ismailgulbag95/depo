import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flame/game.dart';
import 'package:hive_flutter/hive_flutter.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:isar/isar.dart';

import 'package:yeni_oyun_sablon/core/database/database_service.dart';
import 'package:yeni_oyun_sablon/core/localization/localization_service.dart';
import 'package:yeni_oyun_sablon/core/theme/game_theme.dart';
import 'package:yeni_oyun_sablon/features/auction/presentation/live_auction_screen.dart';
import 'package:flame/flame.dart';

void main() async {
  // Flutter binding'lerini başlatıyoruz
  WidgetsFlutterBinding.ensureInitialized();
  
  // Flame'in assets/images/ ön ekini sıfırlıyoruz (Doğrudan assets/items/ kullanabilmek için)
  Flame.images.prefix = '';
  
  // Hive Veritabanını Başlatma
  await Hive.initFlutter();
  await Hive.openBox('settingsBox');

  // Çok Dilli Yerelleştirme Servisini Başlatma (TR, EN, RU, ES)
  await LocalizationService.instance.init();
  
  // Evrensel Veritabanı ve Tohumlama Başlatma
  try {
    await DatabaseService.instance.init();
  } catch (e) {
    debugPrint('Veritabanı başlatma notu: $e');
  }

  // Riverpod State Management için ProviderScope ile sarıyoruz
  runApp(
    const ProviderScope(
      child: OyunSablonApp(),
    ),
  );
}

class OyunSablonApp extends StatelessWidget {
  const OyunSablonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Depo Avcıları',
      debugShowCheckedModeBanner: false,
      theme: GameTheme.themeData,
      home: const LiveAuctionScreen(),
    );
  }
}

// Flame oyun motorumuzu çalıştıracağımız ana ekran
class AnaOyunEkrani extends StatelessWidget {
  const AnaOyunEkrani({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // GameWidget, Flame oyununu Flutter UI'ına gömmemizi sağlar
      body: GameWidget(
        game: BenimOyunum(),
      ),
    );
  }
}

// Flame Oyun Sınıfı
class BenimOyunum extends FlameGame {
  @override
  Future<void> onLoad() async {
    super.onLoad();
    
    // Oyun başladığında yüklenecek her şey (karakterler, arka plan, sesler) buraya gelir.
    // Örnek: add(PlayerCharacter());
  }
}
