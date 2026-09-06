import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flame/game.dart';
import 'package:hive_flutter/hive_flutter.dart';
// import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:yeni_oyun_sablon/core/database/database_service.dart';
import 'package:yeni_oyun_sablon/core/theme/game_theme.dart';
import 'package:yeni_oyun_sablon/features/auction/presentation/live_auction_screen.dart';
import 'package:yeni_oyun_sablon/features/city_map/presentation/city_map_screen.dart';
import 'package:yeni_oyun_sablon/features/onboarding/providers/ftue_provider.dart';
import 'package:yeni_oyun_sablon/features/storage_raid/presentation/storage_raid_screen.dart';
import 'package:yeni_oyun_sablon/features/story_intro/presentation/story_intro_screen.dart';
import 'package:flame/flame.dart';
import 'package:yeni_oyun_sablon/core/localization/localization_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Flame.images.prefix = '';

  // Zorunlu Yatay (Landscape) Çift El Modu Kilidi
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  
  await Hive.initFlutter();
  await Hive.openBox('settingsBox');
  await LocalizationService.instance.init();
  
  try {
    await DatabaseService.instance.init();
  } catch (e) {
    debugPrint('Veritabanı başlatma notu: $e');
  }

  runApp(
    const ProviderScope(
      child: OyunSablonApp(),
    ),
  );
}

class OyunSablonApp extends ConsumerWidget {
  const OyunSablonApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ftueStep = ref.watch(ftueProvider);

    Widget homeWidget;
    switch (ftueStep) {
      case FTUEStep.storyIntro:
        homeWidget = const StoryIntroScreen();
        break;
      case FTUEStep.scriptedAuction:
        homeWidget = const LiveAuctionScreen(isFirstAuction: true);
        break;
      case FTUEStep.tetrisTutorial:
        homeWidget = const StorageRaidScreen();
        break;
      default:
        homeWidget = const CityMapScreen();
        break;
    }

    return MaterialApp(
      title: 'Depo Avcıları',
      debugShowCheckedModeBanner: false,
      theme: GameTheme.themeData,
      home: homeWidget,
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
