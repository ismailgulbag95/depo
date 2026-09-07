import 'package:yeni_oyun_sablon/core/database/models/item_model.dart';

/// 🎩 VIP Koleksiyoncu Özel Sipariş Modeli
class VipOrderModel {
  final String id;
  final String clientName;
  final String clientTitle;
  final String clientAvatar;
  final String requestDescription;
  final String requiredCategory;
  final String requiredItemNamePattern;
  final int minBaseValue;
  final int cashReward;
  final int xpReward;
  final bool isCompleted;

  const VipOrderModel({
    required this.id,
    required this.clientName,
    required this.clientTitle,
    required this.clientAvatar,
    required this.requestDescription,
    required this.requiredCategory,
    required this.requiredItemNamePattern,
    required this.minBaseValue,
    required this.cashReward,
    required this.xpReward,
    this.isCompleted = false,
  });

  /// Eşyanın bu VIP siparişe uygun olup olmadığını test eder
  bool matchesItem(ItemModel item) {
    if (isCompleted) return false;
    if (item.baseValue < minBaseValue) return false;

    // Kategori kontrolü
    if (requiredCategory.isNotEmpty && requiredCategory != 'all') {
      if (item.category.toLowerCase() != requiredCategory.toLowerCase()) {
        return false;
      }
    }

    // İsim kalıbı kontrolü (varsa)
    if (requiredItemNamePattern.isNotEmpty) {
      if (!item.nameTr.toLowerCase().contains(requiredItemNamePattern.toLowerCase())) {
        return false;
      }
    }

    return true;
  }

  VipOrderModel copyWith({
    String? id,
    String? clientName,
    String? clientTitle,
    String? clientAvatar,
    String? requestDescription,
    String? requiredCategory,
    String? requiredItemNamePattern,
    int? minBaseValue,
    int? cashReward,
    int? xpReward,
    bool? isCompleted,
  }) {
    return VipOrderModel(
      id: id ?? this.id,
      clientName: clientName ?? this.clientName,
      clientTitle: clientTitle ?? this.clientTitle,
      clientAvatar: clientAvatar ?? this.clientAvatar,
      requestDescription: requestDescription ?? this.requestDescription,
      requiredCategory: requiredCategory ?? this.requiredCategory,
      requiredItemNamePattern: requiredItemNamePattern ?? this.requiredItemNamePattern,
      minBaseValue: minBaseValue ?? this.minBaseValue,
      cashReward: cashReward ?? this.cashReward,
      xpReward: xpReward ?? this.xpReward,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
