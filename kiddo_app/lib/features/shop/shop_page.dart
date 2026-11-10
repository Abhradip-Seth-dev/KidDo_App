import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:kiddo_app/core/models/shop_item_model.dart';
import 'package:kiddo_app/core/providers/shop_provider.dart';
import 'package:kiddo_app/core/providers/user_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ShopPage — full rewards / items store
// ─────────────────────────────────────────────────────────────────────────────
class ShopPage extends ConsumerStatefulWidget {
  const ShopPage({super.key});

  @override
  ConsumerState<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends ConsumerState<ShopPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userProvider);
    final shopState = ref.watch(shopProvider);
    final int userCoins = userAsync.value?.coins ?? 0;

    // Show toast if there's a purchase message
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (shopState.lastMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              shopState.lastMessage!,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            backgroundColor: const Color(0xff7c3aed),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        ref.read(shopProvider.notifier).clearMessage();
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F9), // Soft clean background
      body: Column(
        children: [
          // ── Top Curved Gradient Header with Integrated Tabs ──────────
          _buildHeader(userCoins),

          // ── Tab Contents ─────────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: const BouncingScrollPhysics(),
              children: [
                _buildGrid(ShopCategory.avatar, shopState),
                _buildGrid(ShopCategory.theme, shopState),
                _buildGrid(ShopCategory.powerUp, shopState),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Header with Gradient & Tabs ─────────────────────────────────────
  Widget _buildHeader(int coins) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6D28D9), Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6D28D9).withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Title + Coin Pill Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    '🛍️ KidDO Shop',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1),

                  // Coin Balance Pill
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.35),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/images/coin.png',
                          height: 18,
                          width: 18,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '$coins Coins',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ).animate().scale(delay: 150.ms, curve: Curves.elasticOut),
                ],
              ),

              const SizedBox(height: 6),
              Text(
                'Spend your coins on cool rewards & avatars!',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 18),

              // ── Tab Bar ───────────────────────────────────────────────
              Container(
                height: 46,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: const Color(0xFF6D28D9),
                  unselectedLabelColor: Colors.white.withOpacity(0.9),
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                  tabs: const [
                    Tab(text: '🧑 Avatars'),
                    Tab(text: '🎨 Themes'),
                    Tab(text: '⚡ Power-ups'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Item Grid ─────────────────────────────────────────────────────
  Widget _buildGrid(ShopCategory category, ShopState shopState) {
    final items = kShopCatalogue.where((i) => i.category == category).toList();

    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 120), // Bottom padding for navbar
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.74,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) => _buildItemCard(items[index], shopState)
          .animate(delay: (index * 70).ms)
          .fadeIn(duration: 350.ms)
          .slideY(begin: 0.2, curve: Curves.easeOut),
    );
  }

  // ── Item Card ─────────────────────────────────────────────────────
  Widget _buildItemCard(ShopItem item, ShopState shopState) {
    final userCoins = ref.watch(userProvider).value?.coins ?? 0;
    final isOwned = shopState.isOwned(item.id);
    final canAfford = userCoins >= item.coinCost;

    return GestureDetector(
      onTap: isOwned ? null : () => _showPurchaseSheet(item),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: isOwned
              ? Border.all(color: const Color(0xFF10B981), width: 2)
              : Border.all(color: const Color(0xFFE2E8F0), width: 1),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7C3AED).withOpacity(0.06),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image / Art Area
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: item.category == ShopCategory.avatar
                      ? const Color(0xFFF6F3FF)
                      : item.category == ShopCategory.theme
                          ? const Color(0xFFEFF6FF)
                          : const Color(0xFFFFFBEB),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(21),
                  ),
                ),
                padding: const EdgeInsets.all(12),
                alignment: Alignment.center,
                child: item.category == ShopCategory.avatar
                    ? Image.asset(
                        item.imageAsset,
                        fit: BoxFit.contain,
                      )
                    : Text(
                        item.emoji,
                        style: const TextStyle(fontSize: 48),
                      ),
              ),
            ),

            // Card Bottom Info
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: Color(0xFF1E1B4B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Button Status
                  SizedBox(
                    width: double.infinity,
                    height: 34,
                    child: isOwned
                        ? Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.check_circle_rounded,
                                  color: Color(0xFF16A34A),
                                  size: 15,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Owned',
                                  style: TextStyle(
                                    color: Color(0xFF16A34A),
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Container(
                            decoration: BoxDecoration(
                              color: canAfford
                                  ? const Color(0xFF7C3AED)
                                  : const Color(0xFFE2E8F0),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: canAfford
                                  ? [
                                      BoxShadow(
                                        color: const Color(0xFF7C3AED)
                                            .withOpacity(0.3),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/images/coin.png',
                                  height: 14,
                                  width: 14,
                                  fit: BoxFit.contain,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${item.coinCost}',
                                  style: TextStyle(
                                    color: canAfford
                                        ? Colors.white
                                        : const Color(0xFF64748B),
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Purchase Confirmation Sheet ───────────────────────────────────
  void _showPurchaseSheet(ShopItem item) {
    ref.read(shopProvider.notifier).setPendingPurchase(item.id);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _PurchaseSheet(item: item),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Purchase Confirmation Bottom Sheet
// ─────────────────────────────────────────────────────────────────────────────
class _PurchaseSheet extends ConsumerWidget {
  final ShopItem item;

  const _PurchaseSheet({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shopState = ref.watch(shopProvider);
    final userCoins = ref.watch(userProvider).value?.coins ?? 0;
    final canAfford = userCoins >= item.coinCost;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 36),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(height: 20),

          // Item art
          if (item.category == ShopCategory.avatar)
            SizedBox(
              height: 110,
              child: Image.asset(item.imageAsset, fit: BoxFit.contain),
            )
          else
            Text(item.emoji, style: const TextStyle(fontSize: 64)),

          const SizedBox(height: 14),
          Text(
            item.name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1E1B4B),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            item.description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),

          // Cost row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/coin.png',
                  height: 20,
                  width: 20,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 6),
                Text(
                  '${item.coinCost} Coins',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFB45309),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '(You have: $userCoins)',
                  style: const TextStyle(
                    color: Color(0xFF78350F),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    ref.read(shopProvider.notifier).cancelPurchase();
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: canAfford && !shopState.isPurchasing
                      ? () async {
                          final success = await ref
                              .read(shopProvider.notifier)
                              .confirmPurchase();
                          if (context.mounted) Navigator.pop(context);
                          if (!success && context.mounted) {
                            // Message already set in notifier
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C3AED),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFFE2E8F0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                  ),
                  child: shopState.isPurchasing
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          canAfford ? 'Buy Now 🛍️' : 'Not Enough Coins',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            color: canAfford ? Colors.white : const Color(0xFF94A3B8),
                          ),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
