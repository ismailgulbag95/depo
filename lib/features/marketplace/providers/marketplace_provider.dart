import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yeni_oyun_sablon/core/database/models/item_model.dart';
import 'package:yeni_oyun_sablon/features/player_profile/providers/player_profile_provider.dart';

/// Müşteri Teklifi Modeli
class CustomerOffer {
  final String customerName;
  final String avatar;
  final int offeredPrice;
  final String dialogue;

  CustomerOffer({
    required this.customerName,
    required this.avatar,
    required this.offeredPrice,
    required this.dialogue,
  });
}

/// Pazar Yeri Satış Durumu
class MarketplaceState {
  final ItemModel? activeItem;
  final double priceMultiplier; // %50 (0.5x) - %300 (3.0x)
  final bool isListed; // İlanda mı?
  final CustomerOffer? currentOffer; // Gelen müşteri teklifi
  final bool isSold; // Satıldı mı?
  final int finalSalePrice; // Son satış tutarı

  const MarketplaceState({
    this.activeItem,
    this.priceMultiplier = 1.0,
    this.isListed = false,
    this.currentOffer,
    this.isSold = false,
    this.finalSalePrice = 0,
  });

  int get listingPrice {
    if (activeItem == null) return 0;
    return (activeItem!.baseValue * priceMultiplier).round();
  }

  MarketplaceState copyWith({
    ItemModel? activeItem,
    bool clearActiveItem = false,
    double? priceMultiplier,
    bool? isListed,
    CustomerOffer? currentOffer,
    bool clearOffer = false,
    bool? isSold,
    int? finalSalePrice,
  }) {
    return MarketplaceState(
      activeItem: clearActiveItem ? null : (activeItem ?? this.activeItem),
      priceMultiplier: priceMultiplier ?? this.priceMultiplier,
      isListed: isListed ?? this.isListed,
      currentOffer: clearOffer ? null : (currentOffer ?? this.currentOffer),
      isSold: isSold ?? this.isSold,
      finalSalePrice: finalSalePrice ?? this.finalSalePrice,
    );
  }
}

/// Pazar Yeri ve Satış Yöneticisi (Poisson Simülasyonu)
class MarketplaceNotifier extends StateNotifier<MarketplaceState> {
  final Ref ref;
  Timer? _customerTimer;
  final Random _rnd = Random();

  MarketplaceNotifier(this.ref) : super(const MarketplaceState());

  void setItemForSale(ItemModel item) {
    _customerTimer?.cancel();
    state = MarketplaceState(
      activeItem: item,
      priceMultiplier: 1.0,
      isListed: false,
      currentOffer: null,
      isSold: false,
      finalSalePrice: 0,
    );
  }

  void updatePriceMultiplier(double multiplier) {
    state = state.copyWith(priceMultiplier: multiplier);
  }

  /// Eşyayı vitrine / ilana koy
  void listForSale() {
    if (state.activeItem == null) return;
    state = state.copyWith(isListed: true, clearOffer: true);

    _scheduleNextCustomer();
  }

  /// Poisson müşteri akışı simülasyonu
  void _scheduleNextCustomer() {
    _customerTimer?.cancel();
    if (!state.isListed || state.isSold) return;

    // Fiyat ne kadar yüksekse müşteri o kadar geç gelir
    final delaySeconds = (state.priceMultiplier * 2.5).clamp(1.5, 6.0);
    _customerTimer = Timer(Duration(milliseconds: (delaySeconds * 1000).toInt()), () {
      if (!mounted || !state.isListed || state.isSold) return;

      _generateCustomerOffer();
    });
  }

  /// Müşteri Teklifi Üretimi
  void _generateCustomerOffer() {
    final askingPrice = state.listingPrice;

    // Fiyat çok ucuzsa (%80 altı) doğrudan talep edilen fiyattan anında kapışılır
    if (state.priceMultiplier <= 0.85) {
      acceptOffer(askingPrice);
      return;
    }

    final customers = [
      (name: 'Koleksiyoncu Selim', avatar: '🧐', factor: 0.95, phrase: 'Bunu uzun süredir arıyordum. Biraz indirim yaparsan hemen nakit alırım!'),
      (name: 'Hurdacı Rıza', avatar: '🧢', factor: 0.70, phrase: 'Bu parçanın piyasası düştü usta. İşimizi görsün diye şu kadar veririm.'),
      (name: 'Antikacı Melahat', avatar: '🕶️', factor: 0.90, phrase: 'Restorasyonu fena değil, vitrinime koyarım. Anlaşırsak el sıkışalım.'),
      (name: 'Tüccar Kenan', avatar: '💼', factor: 0.85, phrase: 'Toplu alım yapıyorum, son fiyata bırakırsan hemen kasadan ödeyeyim.'),
    ];

    final chosen = customers[_rnd.nextInt(customers.length)];
    final offerPrice = (askingPrice * chosen.factor).round();

    state = state.copyWith(
      currentOffer: CustomerOffer(
        customerName: chosen.name,
        avatar: chosen.avatar,
        offeredPrice: offerPrice,
        dialogue: chosen.phrase,
      ),
    );
  }

  /// Müşteri teklifini kabul et ve parayı kasaya ekle
  void acceptOffer([int? customPrice]) {
    final price = customPrice ?? state.currentOffer?.offeredPrice ?? state.listingPrice;
    _customerTimer?.cancel();

    // Parayı oyuncunun profiline ekle
    ref.read(playerProfileProvider.notifier).addCash(price);

    state = state.copyWith(
      isSold: true,
      finalSalePrice: price,
      isListed: false,
    );
  }

  /// Teklifi reddet ve yeni müşteri bekle
  void rejectOffer() {
    state = state.copyWith(clearOffer: true);
    _scheduleNextCustomer();
  }

  @override
  void dispose() {
    _customerTimer?.cancel();
    super.dispose();
  }
}

/// Global Marketplace Provider'ı
final marketplaceProvider =
    StateNotifierProvider<MarketplaceNotifier, MarketplaceState>((ref) {
  return MarketplaceNotifier(ref);
});
