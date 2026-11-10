import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:kiddo_app/core/models/shop_item_model.dart';
import 'package:kiddo_app/core/providers/user_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ShopState — tracks owned items and pending purchase
// ─────────────────────────────────────────────────────────────────────────────
class ShopState {
  final Set<String> ownedItemIds;
  final String? pendingPurchaseId; // item being confirmed
  final bool isPurchasing;
  final String? lastMessage; // toast message

  const ShopState({
    this.ownedItemIds = const {},
    this.pendingPurchaseId,
    this.isPurchasing = false,
    this.lastMessage,
  });

  ShopState copyWith({
    Set<String>? ownedItemIds,
    String? pendingPurchaseId,
    bool? isPurchasing,
    String? lastMessage,
    bool clearPending = false,
    bool clearMessage = false,
  }) {
    return ShopState(
      ownedItemIds: ownedItemIds ?? this.ownedItemIds,
      pendingPurchaseId: clearPending ? null : (pendingPurchaseId ?? this.pendingPurchaseId),
      isPurchasing: isPurchasing ?? this.isPurchasing,
      lastMessage: clearMessage ? null : (lastMessage ?? this.lastMessage),
    );
  }

  bool isOwned(String id) => ownedItemIds.contains(id);
}

// ─────────────────────────────────────────────────────────────────────────────
// ShopNotifier
// ─────────────────────────────────────────────────────────────────────────────
class ShopNotifier extends StateNotifier<ShopState> {
  final Ref _ref;

  ShopNotifier(this._ref) : super(const ShopState());

  void setPendingPurchase(String itemId) {
    state = state.copyWith(pendingPurchaseId: itemId, clearMessage: true);
  }

  void cancelPurchase() {
    state = state.copyWith(clearPending: true);
  }

  /// Attempt to purchase the pending item.
  /// Returns true if successful.
  Future<bool> confirmPurchase() async {
    final itemId = state.pendingPurchaseId;
    if (itemId == null) return false;

    final item = kShopCatalogue.firstWhere((i) => i.id == itemId);
    final user = _ref.read(userProvider).value;
    if (user == null) return false;

    if (user.coins < item.coinCost) {
      state = state.copyWith(
        clearPending: true,
        lastMessage: 'Not enough coins! Earn more by completing quizzes. 🪙',
      );
      return false;
    }

    state = state.copyWith(isPurchasing: true);

    // Deduct coins via repository
    final repo = _ref.read(userRepositoryProvider);
    await repo.updateProgress(
      userId: user.id,
      iqDelta: 0,
      coinsEarned: -item.coinCost,
    );

    // Invalidate the userProvider so UI refreshes
    _ref.invalidate(userProvider);

    final newOwned = {...state.ownedItemIds, itemId};
    state = state.copyWith(
      ownedItemIds: newOwned,
      isPurchasing: false,
      clearPending: true,
      lastMessage: '${item.emoji} ${item.name} purchased! Enjoy!',
    );
    return true;
  }

  void clearMessage() {
    state = state.copyWith(clearMessage: true);
  }
}

final shopProvider = StateNotifierProvider<ShopNotifier, ShopState>((ref) {
  return ShopNotifier(ref);
});
