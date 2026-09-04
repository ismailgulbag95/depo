/// Depo Açık Artırma / Satış Türü
enum StorageAuctionType {
  onSite,       // Yerinde Canlı İhale (Kepenk kısa süreli aralanır)
  onlineAuction // Oyun içi Web Sitesi İlanı (Fotoğraf, ebat, koli sayısı, teklif takibi)
}

/// Depo İçindeki Eşyanın Yerleşim ve Görünürlük Kaydı (Pure Dart)
class RaidItemRecord {
  String? itemCode;
  int? layer;
  double? posX;
  double? posY;
  bool isDiscovered;
  bool isLooted;

  RaidItemRecord({
    this.itemCode,
    this.layer = 1,
    this.posX = 0.5,
    this.posY = 0.5,
    this.isDiscovered = false,
    this.isLooted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'itemCode': itemCode,
      'layer': layer,
      'posX': posX,
      'posY': posY,
      'isDiscovered': isDiscovered,
      'isLooted': isLooted,
    };
  }

  factory RaidItemRecord.fromMap(Map<dynamic, dynamic> map) {
    return RaidItemRecord(
      itemCode: map['itemCode'] as String?,
      layer: map['layer'] as int? ?? 1,
      posX: (map['posX'] as num?)?.toDouble() ?? 0.5,
      posY: (map['posY'] as num?)?.toDouble() ?? 0.5,
      isDiscovered: map['isDiscovered'] as bool? ?? false,
      isLooted: map['isLooted'] as bool? ?? false,
    );
  }
}

/// Depo Modeli (Pure Dart)
class StorageUnitModel {
  int id;
  String title;
  String archetype;
  StorageAuctionType auctionType;
  String unitDimensions;
  int estimatedBoxCount;
  int startingBid;
  int currentBid;
  bool highestBidderIsPlayer;
  int? onlineAuctionDeadlineMs;
  bool isAuctionWon;
  bool isRaidCompleted;
  List<RaidItemRecord> items;

  StorageUnitModel({
    required this.id,
    required this.title,
    required this.archetype,
    this.auctionType = StorageAuctionType.onSite,
    required this.unitDimensions,
    this.estimatedBoxCount = 10,
    this.startingBid = 200,
    this.currentBid = 200,
    this.highestBidderIsPlayer = false,
    this.onlineAuctionDeadlineMs,
    this.isAuctionWon = false,
    this.isRaidCompleted = false,
    this.items = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'archetype': archetype,
      'auctionType': auctionType.name,
      'unitDimensions': unitDimensions,
      'estimatedBoxCount': estimatedBoxCount,
      'startingBid': startingBid,
      'currentBid': currentBid,
      'highestBidderIsPlayer': highestBidderIsPlayer,
      'onlineAuctionDeadlineMs': onlineAuctionDeadlineMs,
      'isAuctionWon': isAuctionWon,
      'isRaidCompleted': isRaidCompleted,
      'items': items.map((e) => e.toMap()).toList(),
    };
  }

  factory StorageUnitModel.fromMap(Map<dynamic, dynamic> map) {
    return StorageUnitModel(
      id: map['id'] as int? ?? 1,
      title: map['title'] as String? ?? '',
      archetype: map['archetype'] as String? ?? 'general',
      auctionType: StorageAuctionType.values.firstWhere(
        (a) => a.name == map['auctionType'],
        orElse: () => StorageAuctionType.onSite,
      ),
      unitDimensions: map['unitDimensions'] as String? ?? '3x4 metre',
      estimatedBoxCount: map['estimatedBoxCount'] as int? ?? 10,
      startingBid: (map['startingBid'] as num?)?.toInt() ?? 200,
      currentBid: (map['currentBid'] as num?)?.toInt() ?? 200,
      highestBidderIsPlayer: map['highestBidderIsPlayer'] as bool? ?? false,
      onlineAuctionDeadlineMs: map['onlineAuctionDeadlineMs'] as int?,
      isAuctionWon: map['isAuctionWon'] as bool? ?? false,
      isRaidCompleted: map['isRaidCompleted'] as bool? ?? false,
      items: (map['items'] as List<dynamic>?)
              ?.map((e) => RaidItemRecord.fromMap(e as Map<dynamic, dynamic>))
              .toList() ??
          [],
    );
  }
}
