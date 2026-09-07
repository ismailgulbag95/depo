import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yeni_oyun_sablon/core/database/models/item_model.dart';
import 'package:yeni_oyun_sablon/features/marketplace/models/web_listing_model.dart';
import 'package:yeni_oyun_sablon/features/onboarding/providers/ftue_provider.dart';
import 'package:yeni_oyun_sablon/features/player_profile/providers/player_profile_provider.dart';

/// İnternet Satış Masası Durumu
class WebMarketplaceState {
  final List<WebListingModel> listings;

  const WebMarketplaceState({
    this.listings = const [],
  });

  WebMarketplaceState copyWith({
    List<WebListingModel>? listings,
  }) {
    return WebMarketplaceState(
      listings: listings ?? this.listings,
    );
  }
}

/// İnternet İlan Yöneticisi (Çalışma Masası PC)
class WebMarketplaceNotifier extends StateNotifier<WebMarketplaceState> {
  final Ref ref;
  Timer? _timer;
  final Random _rnd = Random();

  final List<Map<String, String>> _buyerQuotes = [
    {'name': 'Koleksiyoncu Ahmet', 'quote': 'Uzun süredir bu parçayı arıyordum!'},
    {'name': 'Hurdacı Niyazi', 'quote': 'Bu fiyata hayatta satamazsın patron, nakit teklifim bu!'},
    {'name': 'Antikacı Selin', 'quote': 'Koleksiyonuma çok yakışacak, fiyatta anlaşırsak hemen alırım.'},
    {'name': 'Tamirci Usta Cemil', 'quote': 'Atölyemde işime yarar ama bütçem bu kadarına yetiyor.'},
    {'name': 'Öğrenci Berk', 'quote': 'Biraz indirim yaparsan hemen elden nakit veririm abi.'},
    {'name': 'Mühendis Melis', 'quote': 'Mekanik aksamı fena değil, verdiğim teklif piyasanın üstünde.'},
  ];

  WebMarketplaceNotifier(this.ref) : super(const WebMarketplaceState()) {
    _startSimulationTimer();
  }

  void _startSimulationTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      _tickSimulation();
    });
  }

  void _tickSimulation() {
    if (state.listings.isEmpty) return;

    bool changed = false;
    final updated = <WebListingModel>[];

    for (final listing in state.listings) {
      if (listing.isSold) {
        updated.add(listing);
        continue;
      }

      // Halihazırda bekleyen bir teklif varsa teklif cevaplanana kadar bekle
      if (listing.pendingOfferPrice != null) {
        updated.add(listing);
        continue;
      }

      final newTicks = listing.ticksAlive + 1;

      // 🎯 FTUE Rehberinde Hızlı Satış Garantisi (İlk satışta oyuncu bekletilmez)
      final isFTUEMarket = ref.read(ftueProvider) == FTUEStep.marketplaceFirstSale;
      if (isFTUEMarket) {
        final buyer = _buyerQuotes[_rnd.nextInt(_buyerQuotes.length)];
        updated.add(listing.copyWith(
          isSold: true,
          offerCustomerName: buyer['name'],
          offerMessage: 'Harika bir parça, tam aradığım şeydi! İlanı hemen satın aldım.',
          ticksAlive: newTicks,
        ));
        changed = true;
        continue;
      }

      final roll = _rnd.nextDouble();

      // Talep seviyesine göre teklif veya anında alıcı simülasyonu
      if (listing.demandLevel == MarketDemandLevel.high) {
        // Yüksek talep: Hızlı tam fiyat alımı veya çok cazip teklif
        if (roll < 0.40) {
          // Doğrudan tam fiyattan satıldı!
          final buyer = _buyerQuotes[_rnd.nextInt(_buyerQuotes.length)];
          updated.add(listing.copyWith(
            isSold: true,
            offerCustomerName: buyer['name'],
            offerMessage: 'Fiyat gayet iyi, ilanı hemen satın aldım!',
            ticksAlive: newTicks,
          ));
          changed = true;
          continue;
        } else if (roll < 0.70) {
          // Ufak pazarlık teklifi (%90 - %98)
          final offerPrice = (listing.listingPrice * (0.90 + _rnd.nextDouble() * 0.08)).round();
          final buyer = _buyerQuotes[_rnd.nextInt(_buyerQuotes.length)];
          updated.add(listing.copyWith(
            pendingOfferPrice: offerPrice,
            offerCustomerName: buyer['name'],
            offerMessage: buyer['quote'],
            ticksAlive: newTicks,
          ));
          changed = true;
          continue;
        }
      } else if (listing.demandLevel == MarketDemandLevel.normal) {
        // Normal talep: %25 doğrudan satış, %40 pazarlık
        if (roll < 0.25) {
          final buyer = _buyerQuotes[_rnd.nextInt(_buyerQuotes.length)];
          updated.add(listing.copyWith(
            isSold: true,
            offerCustomerName: buyer['name'],
            offerMessage: 'İlan fiyatınızdan satın aldım.',
            ticksAlive: newTicks,
          ));
          changed = true;
          continue;
        } else if (roll < 0.65) {
          final offerPrice = (listing.listingPrice * (0.78 + _rnd.nextDouble() * 0.14)).round();
          final buyer = _buyerQuotes[_rnd.nextInt(_buyerQuotes.length)];
          updated.add(listing.copyWith(
            pendingOfferPrice: offerPrice,
            offerCustomerName: buyer['name'],
            offerMessage: buyer['quote'],
            ticksAlive: newTicks,
          ));
          changed = true;
          continue;
        }
      } else {
        // Düşük talep (Fahiş fiyat): Nadiren tam alıcı, daha çok sert pazarlık
        if (roll < 0.08) {
          final buyer = _buyerQuotes[_rnd.nextInt(_buyerQuotes.length)];
          updated.add(listing.copyWith(
            isSold: true,
            offerCustomerName: buyer['name'],
            offerMessage: 'Pahalı ama bu eşyayı kaçıramazdım!',
            ticksAlive: newTicks,
          ));
          changed = true;
          continue;
        } else if (roll < 0.45) {
          // Sert pazarlık (%65 - %80)
          final offerPrice = (listing.listingPrice * (0.65 + _rnd.nextDouble() * 0.15)).round();
          final buyer = _buyerQuotes[_rnd.nextInt(_buyerQuotes.length)];
          updated.add(listing.copyWith(
            pendingOfferPrice: offerPrice,
            offerCustomerName: buyer['name'],
            offerMessage: buyer['quote'],
            ticksAlive: newTicks,
          ));
          changed = true;
          continue;
        }
      }

      updated.add(listing.copyWith(ticksAlive: newTicks));
    }

    if (changed) {
      state = state.copyWith(listings: updated);
    }
  }

  /// Yeni internet ilanı oluştur
  void createListing({
    required ItemModel item,
    required int listingPrice,
  }) {
    final demand = WebListingModel.calculateDemandLevel(
      baseValue: item.baseValue,
      listingPrice: listingPrice,
    );

    // Taban fiyattan %15 veya daha ucuzsa anında piyasada kapışılır
    final isInstant = listingPrice <= (item.baseValue * 0.85);

    final listing = WebListingModel(
      id: 'web_${DateTime.now().millisecondsSinceEpoch}_${item.id}',
      item: item,
      listingPrice: listingPrice,
      demandLevel: demand,
      isSold: isInstant,
      offerCustomerName: isInstant ? 'Koleksiyoncu Ahmet' : null,
      offerMessage: isInstant ? 'Kelepir fiyata bulunca saniyesinde satın aldım!' : null,
      ticksAlive: 0,
    );

    final updated = List<WebListingModel>.from(state.listings)..add(listing);
    state = state.copyWith(listings: updated);

    final isFTUEMarket = ref.read(ftueProvider) == FTUEStep.marketplaceFirstSale;
    if (isFTUEMarket && !isInstant) {
      Timer(const Duration(milliseconds: 1200), () {
        _tickSimulation();
      });
    }
  }

  /// Pazarlık teklifini kabul et ve anında sat
  void acceptOffer(String listingId) {
    final index = state.listings.indexWhere((l) => l.id == listingId);
    if (index == -1) return;

    final listing = state.listings[index];
    if (listing.pendingOfferPrice != null) {
      final finalPrice = listing.pendingOfferPrice!;
      ref.read(playerProfileProvider.notifier).addCash(finalPrice);
      ref.read(playerProfileProvider.notifier).addReputation(25);

      final updated = List<WebListingModel>.from(state.listings)..removeAt(index);
      state = state.copyWith(listings: updated);
    }
  }

  /// Pazarlık teklifini reddet ve ilanı yayında tutmaya devam et
  void rejectOffer(String listingId) {
    final index = state.listings.indexWhere((l) => l.id == listingId);
    if (index == -1) return;

    final listing = state.listings[index];
    final updated = List<WebListingModel>.from(state.listings);
    updated[index] = listing.copyWith(clearOffer: true);
    state = state.copyWith(listings: updated);
  }

  /// Satılan ürünün parasını topla
  void claimSale(String listingId) {
    final index = state.listings.indexWhere((l) => l.id == listingId);
    if (index == -1) return;

    final listing = state.listings[index];
    if (listing.isSold) {
      ref.read(playerProfileProvider.notifier).addCash(listing.listingPrice);
      ref.read(playerProfileProvider.notifier).addReputation(20);

      final updated = List<WebListingModel>.from(state.listings)..removeAt(index);
      state = state.copyWith(listings: updated);
    }
  }

  /// İlanı iptal et ve eşyayı geri al
  ItemModel? cancelListing(String listingId) {
    final index = state.listings.indexWhere((l) => l.id == listingId);
    if (index == -1) return null;

    final listing = state.listings[index];
    final updated = List<WebListingModel>.from(state.listings)..removeAt(index);
    state = state.copyWith(listings: updated);

    // Eşyayı ev deposuna geri ekle
    ref.read(playerProfileProvider.notifier).addToHomeStorage(listing.item.id);
    return listing.item;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

/// Global WebMarketplace Provider'ı
final webMarketplaceProvider =
    StateNotifierProvider<WebMarketplaceNotifier, WebMarketplaceState>((ref) {
  return WebMarketplaceNotifier(ref);
});

