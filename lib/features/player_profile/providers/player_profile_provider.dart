import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yeni_oyun_sablon/core/constants/game_constants.dart';
import 'package:yeni_oyun_sablon/core/database/database_service.dart';
import 'package:yeni_oyun_sablon/core/database/models/player_profile_model.dart';

/// Oyuncu Profil Durumu
class PlayerProfileState {
  final int id;
  final int cash;
  final int reputation;
  final int activeVehicleId;
  final int maxStorageSlots;
  final List<int> shopStorageItemIds;

  const PlayerProfileState({
    required this.id,
    required this.cash,
    required this.reputation,
    required this.activeVehicleId,
    required this.maxStorageSlots,
    required this.shopStorageItemIds,
  });

  PlayerProfileState copyWith({
    int? cash,
    int? reputation,
    int? activeVehicleId,
    int? maxStorageSlots,
    List<int>? shopStorageItemIds,
  }) {
    return PlayerProfileState(
      id: id,
      cash: cash ?? this.cash,
      reputation: reputation ?? this.reputation,
      activeVehicleId: activeVehicleId ?? this.activeVehicleId,
      maxStorageSlots: maxStorageSlots ?? this.maxStorageSlots,
      shopStorageItemIds: shopStorageItemIds ?? this.shopStorageItemIds,
    );
  }

  factory PlayerProfileState.initial() {
    return PlayerProfileState(
      id: 1,
      cash: GameConstants.initialPlayerCash,
      reputation: 0,
      activeVehicleId: 1,
      maxStorageSlots: GameConstants.initialShopStorageSlots,
      shopStorageItemIds: const [],
    );
  }
}

/// Oyuncu Profil ve Cüzdan Durumu Yöneticisi
class PlayerProfileNotifier extends StateNotifier<PlayerProfileState> {
  PlayerProfileNotifier() : super(PlayerProfileState.initial()) {
    loadProfile();
  }

  /// Kayıtlı profili yükler
  Future<void> loadProfile() async {
    try {
      final profile = await DatabaseService.instance.getPlayerProfile();
      if (profile != null) {
        state = PlayerProfileState(
          id: profile.id,
          cash: profile.cash,
          reputation: profile.reputation,
          activeVehicleId: profile.activeVehicleId,
          maxStorageSlots: profile.maxStorageSlots,
          shopStorageItemIds: List<int>.from(profile.shopStorageItemIds),
        );
      }
    } catch (_) {}
  }

  /// Nakit para ekler ve kaydeder
  Future<void> addCash(int amount) async {
    final newCash = state.cash + amount;
    state = state.copyWith(cash: newCash);
    await _persist();
  }

  /// Nakit para düşer (Bakiye yetersizse false döner)
  Future<bool> deductCash(int amount) async {
    if (state.cash < amount) return false;
    final newCash = state.cash - amount;
    state = state.copyWith(cash: newCash);
    await _persist();
    return true;
  }

  /// İtibar / Deneyim puanı ekler
  Future<void> addReputation(int points) async {
    final newRep = state.reputation + points;
    state = state.copyWith(reputation: newRep);
    await _persist();
  }

  /// Dükkan deposuna eşya ekler
  Future<bool> addItemToShopStorage(int itemId) async {
    if (state.shopStorageItemIds.length >= state.maxStorageSlots) {
      return false; // Depo dolu
    }
    final updatedList = List<int>.from(state.shopStorageItemIds)..add(itemId);
    state = state.copyWith(shopStorageItemIds: updatedList);
    await _persist();
    return true;
  }

  /// Dükkan deposundan eşya çıkarır
  Future<bool> removeItemFromShopStorage(int itemId) async {
    if (!state.shopStorageItemIds.contains(itemId)) return false;
    final updatedList = List<int>.from(state.shopStorageItemIds)..remove(itemId);
    state = state.copyWith(shopStorageItemIds: updatedList);
    await _persist();
    return true;
  }

  /// Değişiklikleri kalıcı olarak yazar
  Future<void> _persist() async {
    try {
      final profile = PlayerProfileModel(
        id: state.id,
        cash: state.cash,
        reputation: state.reputation,
        activeVehicleId: state.activeVehicleId,
        maxStorageSlots: state.maxStorageSlots,
        shopStorageItemIds: state.shopStorageItemIds,
      );
      await DatabaseService.instance.savePlayerProfile(profile);
    } catch (_) {}
  }
}

/// Global PlayerProfile Provider'ı
final playerProfileProvider =
    StateNotifierProvider<PlayerProfileNotifier, PlayerProfileState>((ref) {
  return PlayerProfileNotifier();
});
