import 'package:yeni_oyun_sablon/core/database/models/item_model.dart';

/// Piyasa Talep Seviyesi
enum MarketDemandLevel {
  high, // Taban altı veya dengeli: Çok hızlı teklif / anında satış
  normal, // Taban fiyata yakın: Düzenli teklifler
  low, // Taban üstü / fahiş fiyat: Pazarlık teklifleri düşer
}

/// İnternet İlanı Modeli (Çalışma Odası PC Masası)
class WebListingModel {
  final String id;
  final ItemModel item;
  final int listingPrice;
  final bool isSold;
  final int? pendingOfferPrice;
  final String? offerCustomerName;
  final String? offerMessage;
  final MarketDemandLevel demandLevel;
  final int ticksAlive;

  const WebListingModel({
    required this.id,
    required this.item,
    required this.listingPrice,
    this.isSold = false,
    this.pendingOfferPrice,
    this.offerCustomerName,
    this.offerMessage,
    required this.demandLevel,
    this.ticksAlive = 0,
  });

  /// Fiyat oranına göre pazar talep durumunu belirler
  static MarketDemandLevel calculateDemandLevel({
    required int baseValue,
    required int listingPrice,
  }) {
    if (baseValue <= 0) return MarketDemandLevel.normal;
    final ratio = listingPrice / baseValue;
    if (ratio <= 0.90) return MarketDemandLevel.high;
    if (ratio <= 1.25) return MarketDemandLevel.normal;
    return MarketDemandLevel.low;
  }

  WebListingModel copyWith({
    bool? isSold,
    int? pendingOfferPrice,
    String? offerCustomerName,
    String? offerMessage,
    MarketDemandLevel? demandLevel,
    int? ticksAlive,
    bool clearOffer = false,
  }) {
    return WebListingModel(
      id: id,
      item: item,
      listingPrice: listingPrice,
      isSold: isSold ?? this.isSold,
      pendingOfferPrice: clearOffer ? null : (pendingOfferPrice ?? this.pendingOfferPrice),
      offerCustomerName: clearOffer ? null : (offerCustomerName ?? this.offerCustomerName),
      offerMessage: clearOffer ? null : (offerMessage ?? this.offerMessage),
      demandLevel: demandLevel ?? this.demandLevel,
      ticksAlive: ticksAlive ?? this.ticksAlive,
    );
  }
}
