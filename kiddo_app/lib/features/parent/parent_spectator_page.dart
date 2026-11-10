import 'package:flutter/material.dart';
import 'package:kiddo_app/core/services/features_service.dart';

class ParentSpectatorPage extends StatefulWidget {
  const ParentSpectatorPage({super.key});

  @override
  State<ParentSpectatorPage> createState() => _ParentSpectatorPageState();
}

class _ParentSpectatorPageState extends State<ParentSpectatorPage> {
  Map<String, dynamic>? _parentData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMetrics();
  }

  Future<void> _loadMetrics() async {
    final data = await FeaturesService().getParentMetrics();
    if (mounted) {
      setState(() {
        _parentData = data;
        _isLoading = false;
      });
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
          'Parent Spectator Mode 🛡️',
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
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Child Profile Overview Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1D4ED8).withOpacity(0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          height: 56,
                          width: 56,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          padding: const EdgeInsets.all(4),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/images/kido_character.png',
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) =>
                                  const Center(child: Text('🎓', style: TextStyle(fontSize: 28))),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _parentData?['childName'] ?? 'Student',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${_parentData?['gradeClass'] ?? 'Class 3'} • Age ${_parentData?['age'] ?? 8}',
                                style: const TextStyle(
                                  color: Color(0xFFBFDBFE),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Habit Metrics Header
                  const Text(
                    'Habit & Learning Metrics',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Healthy learning habits focused on consistency, not stressful grades.',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF64748B),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Habit Cards Grid
                  Row(
                    children: [
                      _buildHabitCard(
                        title: 'Daily Streak',
                        value: '${_parentData?['habitMetrics']?['currentStreak'] ?? 5} Days',
                        icon: '🔥',
                        color: const Color(0xFFF97316),
                        bgColor: const Color(0xFFFFF7ED),
                      ),
                      const SizedBox(width: 14),
                      _buildHabitCard(
                        title: 'Time Spent Today',
                        value: '${_parentData?['habitMetrics']?['learningMinutesToday'] ?? 20} Mins',
                        icon: '⏱️',
                        color: const Color(0xFF0284C7),
                        bgColor: const Color(0xFFF0F9FF),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  Row(
                    children: [
                      _buildHabitCard(
                        title: 'Modules Cleared',
                        value: '${_parentData?['habitMetrics']?['modulesCompleted'] ?? 3} Units',
                        icon: '📚',
                        color: const Color(0xFF16A34A),
                        bgColor: const Color(0xFFF0FDF4),
                      ),
                      const SizedBox(width: 14),
                      _buildHabitCard(
                        title: 'Quizzes Taken',
                        value: '${_parentData?['habitMetrics']?['totalQuizzesTaken'] ?? 12}',
                        icon: '🎯',
                        color: const Color(0xFF9333EA),
                        bgColor: const Color(0xFFFAF5FF),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Weekly Learning Time Chart
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Weekly Activity (Minutes)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _buildBar('Mon', 15),
                            _buildBar('Tue', 20),
                            _buildBar('Wed', 10),
                            _buildBar('Thu', 25),
                            _buildBar('Fri', 30),
                            _buildBar('Sat', 15),
                            _buildBar('Sun', 20),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // DPDP Privacy Compliance Note (Section 3.1)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                    ),
                    child: Row(
                      children: const [
                        Text('🛡️', style: TextStyle(fontSize: 24)),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Child Data Privacy Compliant: KIDO strictly follows India\'s DPDP Act, COPPA, and GDPR-K. No behavioral ad tracking or third-party data profiling.',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF475569),
                              height: 1.3,
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

  Widget _buildHabitCard({
    required String title,
    required String value,
    required String icon,
    required Color color,
    required Color bgColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(icon, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBar(String day, int minutes) {
    final maxMinutes = 40;
    final heightRatio = (minutes / maxMinutes).clamp(0.1, 1.0);

    return Column(
      children: [
        Container(
          width: 28,
          height: 90 * heightRatio,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF38BDF8), Color(0xFF0284C7)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          day,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Color(0xFF64748B),
          ),
        ),
      ],
    );
  }
}
