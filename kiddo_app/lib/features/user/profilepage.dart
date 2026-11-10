import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:kiddo_app/core/providers/auth_provider.dart';
import 'package:kiddo_app/core/providers/user_provider.dart';
import 'package:kiddo_app/core/services/api_service.dart';

class Profilepage extends ConsumerStatefulWidget {
  const Profilepage({super.key});

  @override
  ConsumerState<Profilepage> createState() => _ProfilepageState();
}

class _ProfilepageState extends ConsumerState<Profilepage> {
  final ApiService _api = ApiService();

  bool _soundEnabled = false;
  bool _musicEnabled = true;
  bool _vibrationEnabled = true;
  bool _darkModeEnabled = false;

  void _openEditProfileDialog(String currentName, String currentClass, int currentAge) {
    final nameCtrl = TextEditingController(text: currentName);
    String selectedClass = currentClass.isNotEmpty ? currentClass : 'Class 3';
    int selectedAge = currentAge > 0 ? currentAge : 8;
    bool isSaving = false;
    String? editError;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return Padding(
            padding: EdgeInsets.fromLTRB(
              24,
              24,
              24,
              MediaQuery.of(ctx).viewInsets.bottom + 24,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Edit Profile ✏️',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1E1E2C),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          value: selectedAge,
                          decoration: InputDecoration(
                            labelText: 'Age',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          items: List.generate(
                            12,
                            (i) => DropdownMenuItem(
                              value: i + 4,
                              child: Text('${i + 4} yrs'),
                            ),
                          ),
                          onChanged: (v) =>
                              setModalState(() => selectedAge = v ?? 8),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: selectedClass.startsWith('Class ')
                              ? selectedClass
                              : 'Class $selectedClass',
                          decoration: InputDecoration(
                            labelText: 'Class',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          items: List.generate(
                            10,
                            (i) => DropdownMenuItem(
                              value: 'Class ${i + 1}',
                              child: Text('Class ${i + 1}'),
                            ),
                          ),
                          onChanged: (v) =>
                              setModalState(() => selectedClass = v ?? 'Class 3'),
                        ),
                      ),
                    ],
                  ),
                  if (editError != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      editError!,
                      style: const TextStyle(color: Colors.red, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 24),
                  isSaving
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF7C3AED),
                          ),
                        )
                      : ElevatedButton(
                          onPressed: () async {
                            final newName = nameCtrl.text.trim();
                            if (newName.isEmpty) {
                              setModalState(
                                  () => editError = 'Name cannot be empty.');
                              return;
                            }

                            setModalState(() {
                              isSaving = true;
                              editError = null;
                            });

                            try {
                              await _api.patch(
                                '/users/profile',
                                data: {
                                  'name': newName,
                                  'gradeClass': selectedClass,
                                  'age': selectedAge,
                                },
                              );
                              ref.invalidate(userProvider);
                              if (!mounted) return;
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Profile updated successfully! ✨'),
                                  backgroundColor: Color(0xFF16A34A),
                                ),
                              );
                            } catch (e) {
                              setModalState(() {
                                isSaving = false;
                                editError = 'Failed to update profile: $e';
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7C3AED),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: const Text(
                            'Save Changes',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showFriendsDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Text('👥 Friends & Squad', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Compete with friends in real-time games, quizzes, and climb the leaderboard together!',
              style: TextStyle(color: Colors.grey, height: 1.4),
            ),
            SizedBox(height: 16),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Color(0xFFFFE082),
                child: Text('👦'),
              ),
              title: Text('Rahul S.', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Level 4 · 420 IQ'),
              trailing: Icon(Icons.star, color: Colors.amber),
            ),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Color(0xFFC8E6C9),
                child: Text('👧'),
              ),
              title: Text('Ananya K.', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Level 5 · 580 IQ'),
              trailing: Icon(Icons.star, color: Colors.amber),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close', style: TextStyle(color: Color(0xFF7C3AED), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Log Out', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to log out of KidDo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('Log Out', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(authProvider.notifier).logout();
      ref.invalidate(userProvider);
      ref.invalidate(leaderboardProvider);
      if (!mounted) return;
      context.go('/auth');
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userProvider);
    final user = userAsync.value;

    final displayName = user?.name ?? 'Satirtha Singha';
    final displayClass = user?.gradeClass ?? 'Class 4';
    final displayEmail = user?.email.isNotEmpty == true
        ? user!.email
        : 'satirtha246@gmail.com';
    final displayAge = user?.age ?? 8;
    final userIq = user?.iq ?? 120;

    // Derive league from IQ
    String leagueName = 'LEGEND LEAGUE';
    Color leagueColor = const Color(0xFF9C6FFD);
    if (userIq < 50) {
      leagueName = 'ROOKIE LEAGUE';
      leagueColor = const Color(0xFF38BDF8);
    } else if (userIq < 150) {
      leagueName = 'MASTER LEAGUE';
      leagueColor = const Color(0xFF22C55E);
    } else if (userIq < 300) {
      leagueName = 'CHAMPION LEAGUE';
      leagueColor = const Color(0xFFF59E0B);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFD5E2EA), // Top soft silver-blue gradient background
      body: Stack(
        children: [
          // ── Top Gradient Background ────────────────────────────────
          Container(
            height: 380,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFD5E2EA), Color(0xFFB8CDD8)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // ── Scrollable Body ────────────────────────────────────────
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 30),
              child: Column(
                children: [
                  // Top navigation bar (Back button)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.of(context).maybePop(),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Color(0xFF1E1E2C),
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── 3D Avatar Area ─────────────────────────────────
                  Center(
                    child: Container(
                      height: 240,
                      width: 240,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/profile_pic.jpg',
                          height: 240,
                          width: 240,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Image.asset(
                            'assets/images/kido_character.png',
                            height: 200,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
                  ),

                  const SizedBox(height: 16),

                  // ── White Profile Rounded Card ─────────────────────
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
                    child: Column(
                      children: [
                        // User Name
                        Text(
                          displayName,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF1E1E2C),
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // League Badge Pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: leagueColor,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: leagueColor.withOpacity(0.35),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                'assets/images/IQ.png',
                                height: 15,
                                width: 15,
                                fit: BoxFit.contain,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                leagueName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 14),

                        // IQ & Coins Stats Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // IQ badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: const Color(0xFFBFDBFE), width: 1.2),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset(
                                    'assets/images/IQ.png',
                                    height: 18,
                                    width: 18,
                                    fit: BoxFit.contain,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '$userIq IQ',
                                    style: const TextStyle(
                                      color: Color(0xFF2563EB),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Coins badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFFBEB),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: const Color(0xFFFDE68A), width: 1.2),
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
                                    '${user?.coins ?? 0} Coins',
                                    style: const TextStyle(
                                      color: Color(0xFFD97706),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),

                        // Info rows with dividers
                        _buildDivider(),
                        _buildInfoRow(Icons.menu_book_rounded, 'Class - $displayClass'),
                        _buildDivider(),
                        _buildInfoRow(Icons.cake_outlined, 'Age - $displayAge Years Old'),
                        _buildDivider(),
                        _buildInfoRow(Icons.email_outlined, 'Email - $displayEmail'),
                        _buildDivider(),

                        const SizedBox(height: 20),

                        // Action buttons (Friends / Edit)
                        Row(
                          children: [
                            // Friends 3D Button (Yellow)
                            Expanded(
                              child: _build3DButton(
                                label: 'Friends',
                                icon: Icons.people_alt_rounded,
                                topColor: const Color(0xFFFBBF24),
                                shadowColor: const Color(0xFFD97706),
                                onTap: _showFriendsDialog,
                              ),
                            ),
                            const SizedBox(width: 14),
                            // Edit 3D Button (Cyan)
                            Expanded(
                              child: _build3DButton(
                                label: 'Edit',
                                icon: Icons.edit_note_rounded,
                                topColor: const Color(0xFF06B6D4),
                                shadowColor: const Color(0xFF0284C7),
                                onTap: () => _openEditProfileDialog(
                                  displayName,
                                  displayClass,
                                  displayAge,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── 3 Achievement Badges Row ───────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildBadge('👑', const Color(0xFFFEF3C7), const Color(0xFFF59E0B)),
                        _buildBadge('⭐', const Color(0xFFDCFCE7), const Color(0xFF22C55E)),
                        _buildBadge('💎', const Color(0xFFF3E8FF), const Color(0xFF9333EA)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Settings Card ──────────────────────────────────
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0).withOpacity(0.7),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      children: [
                        _buildCustomToggleTile(
                          icon: Icons.graphic_eq_rounded,
                          label: 'Sound Effect',
                          value: _soundEnabled,
                          onChanged: (v) => setState(() => _soundEnabled = v),
                        ),
                        _buildSettingsDivider(),
                        _buildCustomToggleTile(
                          icon: Icons.music_note_rounded,
                          label: 'Music',
                          value: _musicEnabled,
                          onChanged: (v) => setState(() => _musicEnabled = v),
                        ),
                        _buildSettingsDivider(),
                        _buildCustomToggleTile(
                          icon: Icons.vibration_rounded,
                          label: 'Vibration',
                          value: _vibrationEnabled,
                          onChanged: (v) => setState(() => _vibrationEnabled = v),
                        ),
                        _buildSettingsDivider(),
                        _buildCustomToggleTile(
                          icon: Icons.dark_mode_rounded,
                          label: 'Dark Mode',
                          value: _darkModeEnabled,
                          onChanged: (v) => setState(() => _darkModeEnabled = v),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // ── Legal & Policy Pill Links ──────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildChipLink('terms & conditions'),
                      const SizedBox(width: 12),
                      _buildChipLink('Privacy & Policy'),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ── Log Out 3D Red Button ──────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GestureDetector(
                      onTap: _handleLogout,
                      child: Stack(
                        children: [
                          // Bottom 3D shadow
                          Container(
                            height: 64,
                            decoration: BoxDecoration(
                              color: const Color(0xFF991B1B),
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          // Top gradient button
                          Container(
                            height: 58,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFF5757), Color(0xFFEF4444)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            alignment: Alignment.center,
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'LOG OUT',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 2,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Icon(
                                  Icons.logout_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Version text
                  const Text(
                    'Version 1.0.0',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Info Row Builder ───────────────────────────────────────────────
  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF64748B)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF334155),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() => Divider(height: 1, color: Colors.grey.withOpacity(0.15));
  Widget _buildSettingsDivider() => Divider(height: 1, color: Colors.white.withOpacity(0.6), indent: 16, endIndent: 16);

  // ── 3D Button Builder ──────────────────────────────────────────────
  Widget _build3DButton({
    required String label,
    required IconData icon,
    required Color topColor,
    required Color shadowColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            height: 52,
            decoration: BoxDecoration(
              color: shadowColor,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          Container(
            height: 47,
            decoration: BoxDecoration(
              color: topColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Achievement Badge Builder ──────────────────────────────────────
  Widget _buildBadge(String emoji, Color bg, Color border) {
    return Container(
      height: 84,
      width: 84,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: border.withOpacity(0.5), width: 3),
        boxShadow: [
          BoxShadow(
            color: border.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Center(
        child: Text(emoji, style: const TextStyle(fontSize: 38)),
      ),
    );
  }

  // ── Custom Styled Gaming Toggle Tile ───────────────────────────────
  Widget _buildCustomToggleTile({
    required IconData icon,
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 22, color: const Color(0xFF334155)),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
          // Custom Gaming Switch
          GestureDetector(
            onTap: () => onChanged(!value),
            child: Container(
              width: 58,
              height: 30,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: value ? const Color(0xFF22C55E) : const Color(0xFF94A3B8),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                children: [
                  Positioned(
                    left: value ? 8 : null,
                    right: !value ? 8 : null,
                    child: Icon(
                      value ? Icons.check : Icons.close,
                      color: Colors.white.withOpacity(0.8),
                      size: 14,
                    ),
                  ),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Chip Link ──────────────────────────────────────────────────────
  Widget _buildChipLink(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0).withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Color(0xFF475569),
        ),
      ),
    );
  }
}
