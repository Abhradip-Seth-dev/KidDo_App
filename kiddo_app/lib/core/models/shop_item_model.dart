enum ShopCategory { avatar, theme, powerUp }
enum ShopItemStatus { available, owned, insufficient }

class ShopItem {
  final String id;
  final String name;
  final String description;
  final String imageAsset;
  final int coinCost;
  final ShopCategory category;
  final String emoji;

  const ShopItem({
    required this.id,
    required this.name,
    required this.description,
    required this.imageAsset,
    required this.coinCost,
    required this.category,
    required this.emoji,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Shop Catalogue
// ─────────────────────────────────────────────────────────────────────────────
const List<ShopItem> kShopCatalogue = [
  // ── Avatars ───────────────────────────────────────────────────────────────
  ShopItem(
    id: 'avatar_star',
    name: 'Star Hero',
    description: 'Shine bright with this golden star avatar!',
    imageAsset: 'assets/images/avatar_star.png',
    coinCost: 200,
    category: ShopCategory.avatar,
    emoji: '⭐',
  ),
  ShopItem(
    id: 'avatar_fire',
    name: 'Flame Champ',
    description: 'Show off your hot streak with this fire avatar!',
    imageAsset: 'assets/images/avatar_fire.png',
    coinCost: 350,
    category: ShopCategory.avatar,
    emoji: '🔥',
  ),
  ShopItem(
    id: 'avatar_robot',
    name: 'Robo Brain',
    description: 'A super-smart robot for the tech genius in you!',
    imageAsset: 'assets/images/avatar_robot.png',
    coinCost: 500,
    category: ShopCategory.avatar,
    emoji: '🤖',
  ),

  // ── Themes ────────────────────────────────────────────────────────────────
  ShopItem(
    id: 'theme_dark',
    name: 'Dark Mode',
    description: 'Easy on the eyes — switch to dark theme!',
    imageAsset: 'assets/images/kido_character.png',
    coinCost: 500,
    category: ShopCategory.theme,
    emoji: '🌙',
  ),
  ShopItem(
    id: 'theme_ocean',
    name: 'Ocean Theme',
    description: 'Dive deep with this cool ocean colour palette.',
    imageAsset: 'assets/images/kido_character.png',
    coinCost: 400,
    category: ShopCategory.theme,
    emoji: '🌊',
  ),

  // ── Power-ups ─────────────────────────────────────────────────────────────
  ShopItem(
    id: 'powerup_xp2',
    name: 'XP Booster',
    description: '2× IQ points for your next quiz session!',
    imageAsset: 'assets/images/kido_character.png',
    coinCost: 100,
    category: ShopCategory.powerUp,
    emoji: '⚡',
  ),
  ShopItem(
    id: 'powerup_hint',
    name: 'Hint Token',
    description: 'Skip one tricky question in any quiz!',
    imageAsset: 'assets/images/kido_character.png',
    coinCost: 75,
    category: ShopCategory.powerUp,
    emoji: '💡',
  ),
  ShopItem(
    id: 'powerup_freeze',
    name: 'Streak Freeze',
    description: 'Protect your daily learning streak even if you miss a day!',
    imageAsset: 'assets/images/kido_character.png',
    coinCost: 50,
    category: ShopCategory.powerUp,
    emoji: '❄️',
  ),
];
