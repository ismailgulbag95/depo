import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:yeni_oyun_sablon/core/constants/asset_paths.dart';

/// 🔊 Merkezi Oyun Ses Yöneticisi (GameAudioService)
/// Web, Windows, Android ve iOS ortamlarında ses efektlerini (SFX) ve ortam seslerini yönetir.
class GameAudioService {
  static GameAudioService? _instance;
  static GameAudioService get instance => _instance ??= GameAudioService._();

  GameAudioService._() {
    _loadMutePreference();
  }

  bool _isMuted = false;
  double _volume = 0.8;

  bool get isMuted => _isMuted;
  double get volume => _volume;

  void _loadMutePreference() {
    try {
      if (Hive.isBoxOpen('settingsBox')) {
        final box = Hive.box('settingsBox');
        _isMuted = box.get('audio_is_muted', defaultValue: false) as bool;
        _volume = (box.get('audio_volume', defaultValue: 0.8) as num).toDouble();
      }
    } catch (_) {}
  }

  Future<void> toggleMute() async {
    _isMuted = !_isMuted;
    try {
      if (Hive.isBoxOpen('settingsBox')) {
        final box = Hive.box('settingsBox');
        await box.put('audio_is_muted', _isMuted);
      }
    } catch (_) {}
  }

  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    try {
      if (Hive.isBoxOpen('settingsBox')) {
        final box = Hive.box('settingsBox');
        await box.put('audio_volume', _volume);
      }
    } catch (_) {}
  }

  /// Ses Efekti Çalma (SFX)
  Future<void> playSfx(String relativePath, {double? volumeMultiplier}) async {
    if (_isMuted) return;

    try {
      final player = AudioPlayer();
      await player.setVolume((_volume * (volumeMultiplier ?? 1.0)).clamp(0.0, 1.0));
      // audioplayers AssetSource expects relative to assets/ directory
      // 'audio/xxx.wav' maps to assets/audio/xxx.wav
      await player.play(AssetSource(relativePath));
      
      // Çalma tamamlandığında kaynakları temizle
      player.onPlayerComplete.listen((_) {
        player.dispose();
      });
    } catch (e) {
      // Web tarayıcısında kullanıcı henüz ekrana tıklamadıysa autoplay kısıtlaması oluşabilir
      debugPrint('Audio play note (non-critical): $e');
    }
  }

  // --- HIZLI KISAYOLLAR ---
  Future<void> playClick() => playSfx(GameAssetPaths.sfxClick, volumeMultiplier: 0.6);
  Future<void> playPack() => playSfx(GameAssetPaths.sfxPack, volumeMultiplier: 0.85);
  Future<void> playGavel() => playSfx(GameAssetPaths.sfxGavel, volumeMultiplier: 1.0);
  Future<void> playCoin() => playSfx(GameAssetPaths.sfxCoin, volumeMultiplier: 0.9);
  Future<void> playCrush() => playSfx(GameAssetPaths.sfxCrush, volumeMultiplier: 1.0);
  Future<void> playHit() => playSfx(GameAssetPaths.sfxHit, volumeMultiplier: 0.9);
  Future<void> playVictory() => playSfx(GameAssetPaths.sfxVictory, volumeMultiplier: 1.0);
  Future<void> playWarning() => playSfx(GameAssetPaths.sfxWarning, volumeMultiplier: 0.7);
}
