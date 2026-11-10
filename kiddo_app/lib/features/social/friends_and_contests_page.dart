import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiddo_app/core/providers/user_provider.dart';
import 'package:kiddo_app/core/services/features_service.dart';

class FriendsAndContestsPage extends ConsumerStatefulWidget {
  const FriendsAndContestsPage({super.key});

  @override
  ConsumerState<FriendsAndContestsPage> createState() =>
      _FriendsAndContestsPageState();
}

class _FriendsAndContestsPageState extends ConsumerState<FriendsAndContestsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Data
  Map<String, dynamic>? _contestData;
  Map<String, dynamic>? _coopQuest;
  List<dynamic> _friends = [];
  List<dynamic> _pendingRequests = [];
  List<dynamic> _friendlyLeaderboard = [];
  bool _isLoading = true;

  final TextEditingController _friendEmailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAllData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _friendEmailController.dispose();
    super.dispose();
  }

  Future<void> _loadAllData() async {
    final features = FeaturesService();
    final contestRes = await features.getContests();
    final questRes = await features.getCoopQuest();
    final friendsData = await features.getFriendsData();
    final friendlyLb = await features.getFriendlyLeaderboard();

    if (mounted) {
      setState(() {
        _contestData = contestRes;
        _coopQuest = questRes;
        _friends = friendsData['friends'] ?? [];
        _pendingRequests = friendsData['pendingRequests'] ?? [];
        _friendlyLeaderboard = friendlyLb;
        _isLoading = false;
      });
    }
  }

  Future<void> _sendFriendRequest() async {
    final email = _friendEmailController.text.trim();
    if (email.isEmpty) return;

    try {
      final msg = await FeaturesService().sendFriendRequest(email);
      _friendEmailController.clear();
      _loadAllData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Arena & Friends ⚔️',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1E293B), size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF0284C7),
          unselectedLabelColor: const Color(0xFF64748B),
          indicatorColor: const Color(0xFF0284C7),
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
          tabs: const [
            Tab(text: '🏆 Championship'),
            Tab(text: '🤝 Friends'),
            Tab(text: '🌟 Co-op Quest'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildContestTab(),
                _buildFriendsTab(),
                _buildCoopQuestTab(),
              ],
            ),
    );
  }

  // ── Tab 1: Monthly Contest Arena ───────────────────────────────────────────
  Widget _buildContestTab() {
    final contest = _contestData?['contest'] as Map<String, dynamic>?;
    final isJoined = _contestData?['isJoined'] == true;

    if (contest == null) {
      return const Center(child: Text('No active championships currently.'));
    }

    final stages = (contest['stages'] as List?) ?? [];
    final participants = (contest['participants'] as List?) ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Contest Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF7C3AED), Color(0xFF4C1D95)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF7C3AED).withOpacity(0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('🏆', style: TextStyle(fontSize: 36)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            contest['title'] ?? 'Championship',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            '${contest['gradeClass']} • ${contest['monthYear']}',
                            style: const TextStyle(
                              color: Color(0xFFDDD6FE),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (!isJoined)
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        await FeaturesService().joinContest(contest['_id']);
                        ref.invalidate(userProvider);
                        _loadAllData();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Registered for the Championship! 🚀')),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(e.toString())),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF59E0B),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text('⚔️', style: TextStyle(fontSize: 18)),
                        SizedBox(width: 8),
                        Text(
                          'Join for 20 Coins',
                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Colors.white),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      '✅ Registered • Compete in Stages Below',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 5 Tournament Stages
          const Text(
            '5-Day Championship Stages',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 12),
          ...List.generate(stages.length, (index) {
            final stage = stages[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: const Color(0xFFEFF6FF),
                    child: Text('${stage['stageNumber']}', style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF0284C7))),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stage['title'] ?? 'Stage',
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF1E293B)),
                        ),
                        Text(
                          '${stage['questionCount']} Questions • 3 Minutes',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  const Text('⭐ Locked', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8))),
                ],
              ),
            );
          }),

          const SizedBox(height: 16),

          // Top Participants
          const Text(
            'Championship Leaderboard',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 10),
          ...List.generate(participants.length, (index) {
            final p = participants[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Text(index == 0 ? '🥇' : index == 1 ? '🥈' : '🥉', style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      p['userName'] ?? 'Competitor',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF1E293B)),
                    ),
                  ),
                  Text(
                    '${p['totalScore']} Pts',
                    style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF0284C7)),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ── Tab 2: Friends & Friendly Leaderboard ──────────────────────────────────
  Widget _buildFriendsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Add Friend Box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Add a Friend ✉️',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF1E293B)),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _friendEmailController,
                        decoration: InputDecoration(
                          hintText: "Enter friend's email",
                          hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _sendFriendRequest,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0284C7),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
                      ),
                      child: const Text('Add', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Pending Requests Section
          if (_pendingRequests.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'Pending Friend Requests 📬',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 8),
            ...List.generate(_pendingRequests.length, (index) {
              final req = _pendingRequests[index];
              final friendUser = req['user'];
              final friendshipId = req['friendshipId'];
              final isIncoming = req['isIncoming'] == true;

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: const Color(0xFFFDE68A),
                      child: Text('👋', style: const TextStyle(fontSize: 18)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        friendUser?['name'] ?? 'Student',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                      ),
                    ),
                    if (isIncoming) ...[
                      IconButton(
                        icon: const Icon(Icons.check_circle, color: Color(0xFF16A34A)),
                        onPressed: () async {
                          await FeaturesService().respondFriendRequest(friendshipId, true);
                          _loadAllData();
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.cancel, color: Color(0xFFDC2626)),
                        onPressed: () async {
                          await FeaturesService().respondFriendRequest(friendshipId, false);
                          _loadAllData();
                        },
                      ),
                    ] else
                      const Text(
                        'Sent',
                        style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF64748B), fontSize: 12),
                      ),
                  ],
                ),
              );
            }),
          ],

          const SizedBox(height: 24),

          // Friendly Zone Leaderboard
          Text(
            'Friendly Zone Leaderboard 🌟 (${_friends.length} Friends)',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 10),
          if (_friendlyLeaderboard.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.center,
              child: const Text(
                'Add your classmates to compete in the Friendly Zone!',
                style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600),
              ),
            )
          else
            ...List.generate(_friendlyLeaderboard.length, (index) {
              final user = _friendlyLeaderboard[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Text('#${index + 1}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF0284C7))),
                    const SizedBox(width: 12),
                    CircleAvatar(
                      backgroundColor: const Color(0xFFEFF6FF),
                      child: Text('🎓', style: const TextStyle(fontSize: 18)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        user['name'] ?? 'Friend',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF1E293B)),
                      ),
                    ),
                    Row(
                      children: [
                        Image.asset('assets/images/IQ.png', height: 18, width: 18),
                        const SizedBox(width: 4),
                        Text(
                          '${user['iq'] ?? 0} IQ',
                          style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF2563EB)),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  // ── Tab 3: Class Co-op Quest ───────────────────────────────────────────────
  Widget _buildCoopQuestTab() {
    final quest = _coopQuest;
    if (quest == null) {
      return const Center(child: Text('No active class quests currently.'));
    }

    final target = quest['targetCount'] ?? 500;
    final current = quest['currentCount'] ?? 0;
    final ratio = (current / target).clamp(0.0, 1.0);
    final contributors = (quest['contributors'] as List?) ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF059669), Color(0xFF047857)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF059669).withOpacity(0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('🤝', style: TextStyle(fontSize: 36)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            quest['title'] ?? 'Classroom Co-op Quest',
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
                          ),
                          Text(
                            quest['gradeClass'] ?? 'Class 3',
                            style: const TextStyle(color: Color(0xFFA7F3D0), fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  quest['description'] ?? '',
                  style: const TextStyle(color: Color(0xFFECFDF5), fontSize: 13, height: 1.3),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('CLASS PROGRESS', style: TextStyle(color: Color(0xFFFDE047), fontSize: 11, fontWeight: FontWeight.w900)),
                    Text('$current / $target Problems', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900)),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: ratio,
                    minHeight: 12,
                    backgroundColor: const Color(0xFF064E3B),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFDE047)),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Top Class Contributors
          const Text(
            'Classroom Top Contributors 🌟',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 12),
          ...List.generate(contributors.length, (index) {
            final c = contributors[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Text('${index + 1}.', style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF059669))),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(c['userName'] ?? 'Classmate', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                  ),
                  Text('${c['count']} Solved', style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF059669))),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
