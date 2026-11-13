import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiddo_app/core/models/user_model.dart';
import 'package:kiddo_app/core/providers/user_provider.dart';

import 'package:kiddo_app/core/services/features_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// LeaderboardPage — redesigned to match the mockup
// ─────────────────────────────────────────────────────────────────────────────
class LeaderboardPage extends ConsumerStatefulWidget {
  const LeaderboardPage({super.key});

  @override
  ConsumerState<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends ConsumerState<LeaderboardPage> {
  int _selectedTabIndex = 0; // 0: Global, 1: Friendly Zone

  @override
  void initState() {
    super.initState();
    _loadFriendly();
  }

  Future<void> _loadFriendly() async {
    await FeaturesService().getFriendlyLeaderboard();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final playersAsync = ref.watch(leaderboardProvider);
    final currentUserAsync = ref.watch(userProvider);

    return playersAsync.when(
      loading: () => const Scaffold(
        backgroundColor: Color(0xffdbe2e8),
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: Color(0xffdbe2e8),
        body: Center(child: Text('Error: $e')),
      ),
      data: (players) {
        final currentUser = currentUserAsync.value;

        return Scaffold(
          backgroundColor: const Color(0xffdbe2e8),
          body: Column(
            children: [
              // ── Top Section (Gradient + Podium + Tabs) ─────────────────
              Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.topCenter,
                    radius: 1.2,
                    colors: [Color(0xfffde68a), Color(0xfff59e0b)],
                  ),
                ),
                child: Column(
                  children: [
                    // Podium section
                    if (players.length >= 3) _buildPodium(context, players),
                    const SizedBox(height: 5),

                    // ── Toggle tabs (Fully rounded white container) ─────
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: const Color(0xffe5e7eb),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          children: [
                            _buildTab('Global', _selectedTabIndex == 0, 0),
                            _buildTab(
                              'Friendly Zone',
                              _selectedTabIndex == 1,
                              1,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),

              // ── Ranked list ────────────────────────────────────────────
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(
                      0xffdbe2e8,
                    ), // Light blue-grey background for list
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                  ),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 5, 20, 10),
                    itemCount: players.length > 3
                        ? players.length - 3
                        : 0, // skip top 3 (shown on podium)
                    itemBuilder: (_, i) {
                      final player = players[i + 3];
                      return _buildRankRow(
                        player,
                        rank: i + 4,
                        isMe: currentUser?.id == player.id,
                      );
                    },
                  ),
                ),
              ),

              // ── Current user sticky row ─────────────────────────────────
              if (currentUser != null)
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xfffbb117), // Yellow/Orange sticky row
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  // Determine rank of current user
                  child: _buildRankRow(
                    currentUser,
                    rank: players.indexWhere((p) => p.id == currentUser.id) + 1,
                    isMe: true,
                  ),
                ),

              // ── Blank space behind bottom nav bar ───────────────────────
              // This ensures the sticky row sits above the nav bar, and nothing shows behind it.
              Container(height: 110, color: const Color(0xfffbb117)),
            ],
          ),
        );
      },
    );
  }

  // ── Podium ─────────────────────────────────────────────────────────
  Widget _buildPodium(BuildContext context, List<UserModel> players) {
    return Container(
      height: 320,
      width: double.infinity,
      // Gradient moved to parent container in build()
      child: SafeArea(
        bottom: false,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            // The podium image
            Image.asset(
              'assets/images/leaderboard.png',
              width: 320, // Adjust width as needed to align with avatars
              fit: BoxFit.contain,
            ),
            // Rank blocks at bottom
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Rank 2
                _PodiumBlock(
                  player: players[1],
                  blockHeight: 65,
                  avatarSize: 55,
                ),
                // Rank 1
                _PodiumBlock(
                  player: players[0],
                  blockHeight: 80,
                  avatarSize: 65,
                  isCrown: true,
                ),
                // Rank 3
                _PodiumBlock(
                  player: players[2],
                  blockHeight: 45,
                  avatarSize: 55,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Toggle tab pill ─────────────────────────────────────────────────
  Widget _buildTab(String label, bool selected, int index) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedTabIndex = index);
          if (index == 1) _loadFriendly();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xfffac62f)
                : Colors.transparent, // Yellow when selected
            borderRadius: BorderRadius.circular(30),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              fontSize: 16,
              color: selected
                  ? const Color(0xfff97316)
                  : const Color(0xff6b7280),
            ),
          ),
        ),
      ),
    );
  }

  // ── Single rank row ─────────────────────────────────────────────────
  Widget _buildRankRow(
    UserModel player, {
    required int rank,
    required bool isMe,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // Rank
          SizedBox(
            width: 28,
            child: Text(
              '$rank.',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: isMe
                    ? Colors.white
                    : const Color(0xff475569), // White if me, dark grey if not
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Avatar
          CircleAvatar(
            radius: 18,
            backgroundColor: isMe
                ? Colors.transparent
                : const Color(0xff94a3b8), // Plain grey circle for others
            backgroundImage: isMe
                ? const AssetImage('assets/images/profile_pic.jpg')
                : null, // No initials
          ),
          const SizedBox(width: 15),

          // Name
          Expanded(
            child: Text(
              player.name,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: isMe
                    ? Colors.white
                    : const Color(0xff1e293b), // White if me, dark blue if not
                fontSize: 16,
              ),
            ),
          ),

          // Score Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xfffde047), // Yellow fill
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xfff97316),
                width: 1.5,
              ), // Orange border
            ),
            child: Row(
              children: [
                Image.asset(
                  'assets/images/IQ.png',
                  height: 16,
                  width: 16,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 4),
                Text(
                  '${player.iq} IQ',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Color(0xffef4444), // Red text
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Podium block widget
// ─────────────────────────────────────────────────────────────────────────────
class _PodiumBlock extends StatelessWidget {
  final UserModel player;
  final double blockHeight;
  final double avatarSize;
  final bool isCrown;

  const _PodiumBlock({
    required this.player,
    required this.blockHeight,
    required this.avatarSize,
    this.isCrown = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Crown
        if (isCrown)
          const Text('👑', style: TextStyle(fontSize: 20))
        else
          const SizedBox(height: 24),
        // Avatar
        CircleAvatar(
          radius: avatarSize / 2,
          backgroundColor: Colors.white,
          child: Text(
            player.name[0],
            style: TextStyle(
              fontSize: avatarSize * 0.4,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 4),
        // Name
        Text(
          player.name,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black, // Dark text matching mockup
          ),
        ),
        const SizedBox(height: 4),
        // Space for the image underneath
        SizedBox(height: blockHeight),
      ],
    );
  }
}

// Removed static _Player class as we are using UserModel now.
