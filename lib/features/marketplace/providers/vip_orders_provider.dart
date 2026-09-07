import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yeni_oyun_sablon/core/database/models/item_model.dart';
import 'package:yeni_oyun_sablon/features/marketplace/models/vip_order_model.dart';
import 'package:yeni_oyun_sablon/features/player_profile/providers/player_profile_provider.dart';

/// 🎩 VIP Koleksiyoncu Siparişleri Listesi
class VipOrdersState {
  final List<VipOrderModel> orders;

  const VipOrdersState({this.orders = const []});

  VipOrdersState copyWith({List<VipOrderModel>? orders}) {
    return VipOrdersState(orders: orders ?? this.orders);
  }
}

class VipOrdersNotifier extends StateNotifier<VipOrdersState> {
  final Ref _ref;

  VipOrdersNotifier(this._ref)
      : super(
          const VipOrdersState(
            orders: [
              VipOrderModel(
                id: 'vip_1',
                clientName: 'Lord Celal',
                clientTitle: 'Antika Müptelası Asilzade',
                clientAvatar: '🧐',
                requestDescription: 'Malikanemin baş köşesi için nadir bir Sanat Eseri veya Antika Obje arıyorum. Sıradan döküntüler değil, gerçek bir şaheser olmalı!',
                requiredCategory: 'sanat_antikalar',
                requiredItemNamePattern: '',
                minBaseValue: 250,
                cashReward: 4800,
                xpReward: 120,
              ),
              VipOrderModel(
                id: 'vip_2',
                clientName: 'Küratör Aylin Hanım',
                clientTitle: 'Şehir Müzesi Baş Uzmanı',
                clientAvatar: '🏛️',
                requestDescription: 'Müzemizin yeni sergisi için nadir maden, değerli taş veya simya eseri arıyoruz. Yüksek bütçemiz ayrıldı.',
                requiredCategory: 'maden_ve_taslar',
                requiredItemNamePattern: '',
                minBaseValue: 300,
                cashReward: 6500,
                xpReward: 180,
              ),
              VipOrderModel(
                id: 'vip_3',
                clientName: 'Koleksiyoncu \'Gölge\'',
                clientTitle: 'Yeraltı Zindan Loncası Temsilcisi',
                clientAvatar: '🥷',
                requestDescription: 'Paralı askerlerimin kuşanabileceği büyülü bir savaş ekipmanı veya kadim silah getirin. Altınına acımam.',
                requiredCategory: 'buyulu_silahlar',
                requiredItemNamePattern: '',
                minBaseValue: 400,
                cashReward: 8500,
                xpReward: 250,
              ),
              VipOrderModel(
                id: 'vip_4',
                clientName: 'Teknoloji Mogulu Berke',
                clientTitle: 'Silikon Vadisi Yatırımcısı',
                clientAvatar: '💻',
                requestDescription: 'Modern ofisim için nadir elektronik veya özel ofis ekipmanı arıyorum. Piyasanın iki katını veririm.',
                requiredCategory: 'ofis_ekipmanlari',
                requiredItemNamePattern: '',
                minBaseValue: 280,
                cashReward: 5200,
                xpReward: 150,
              ),
            ],
          ),
        );

  /// VIP Siparişi Teslim Etme & Ödül Alma
  bool deliverOrder({
    required String orderId,
    required ItemModel item,
  }) {
    final orderIndex = state.orders.indexWhere((o) => o.id == orderId);
    if (orderIndex == -1) return false;

    final order = state.orders[orderIndex];
    if (!order.matchesItem(item)) return false;

    // 1. Ödülleri oyuncuya aktar
    _ref.read(playerProfileProvider.notifier).addCash(order.cashReward);
    _ref.read(playerProfileProvider.notifier).addReputation(order.xpReward);

    // 2. Siparişi tamamlandı olarak işaretle ve yeni bir sipariş türet
    final updatedList = List<VipOrderModel>.from(state.orders);
    updatedList[orderIndex] = order.copyWith(isCompleted: true);

    state = state.copyWith(orders: updatedList);
    return true;
  }
}

final vipOrdersProvider = StateNotifierProvider<VipOrdersNotifier, VipOrdersState>((ref) {
  return VipOrdersNotifier(ref);
});
