import 'package:flutter/material.dart';
import 'package:kiddo_app/core/services/features_service.dart';
import 'package:kiddo_app/features/quiz/adaptive_quiz_page.dart';

class MascotSuggestionBanner extends StatefulWidget {
  final VoidCallback? onActionTap;

  const MascotSuggestionBanner({super.key, this.onActionTap});

  @override
  State<MascotSuggestionBanner> createState() => _MascotSuggestionBannerState();
}

class _MascotSuggestionBannerState extends State<MascotSuggestionBanner> {
  Map<String, dynamic>? _suggestionData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSuggestion();
  }

  Future<void> _loadSuggestion() async {
    // 1. Fetch real-time suggestion from the new Adaptive Learning & Recommendation Engine
    final adaptiveData = await FeaturesService().getAdaptiveProgress();
    if (adaptiveData != null && adaptiveData['mascotSuggestion'] != null) {
      if (mounted) {
        setState(() {
          _suggestionData = adaptiveData;
          _isLoading = false;
        });
      }
      return;
    }

    // 2. Fallback to basic profile suggestion
    final data = await FeaturesService().getAdaptiveSuggestion();
    if (mounted) {
      setState(() {
        _suggestionData = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox.shrink();
    }

    final suggestion = _suggestionData?['mascotSuggestion'] as Map<String, dynamic>?;
    final title = suggestion?['title'] ?? 'KIDO AI Coach';
    final message = suggestion?['message'] ?? 'Keep practicing daily to level up your IQ and earn Coins!';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () async {
            String? topicId = suggestion?['suggestedTopicId'];
            String topicName = suggestion?['suggestedTopicName'] ?? 'Multiplication & Arrays';

            if (topicId == null) {
              final topics = await FeaturesService().getAdaptiveTopics();
              if (topics != null && topics.isNotEmpty) {
                final firstSub = topics[0];
                final subTopics = firstSub['topics'] as List<dynamic>?;
                if (subTopics != null && subTopics.isNotEmpty) {
                  topicId = subTopics[0]['topicId'];
                  topicName = subTopics[0]['topicName'] ?? topicName;
                }
              }
            }

            if (topicId != null && context.mounted) {
              Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute(
                  builder: (_) => AdaptiveQuizPage(
                    topicId: topicId!,
                    topicName: topicName,
                  ),
                ),
              );
            }
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE0F2FE), Color(0xFFF0FDF4)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFF38BDF8), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0284C7).withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(6),
                  child: Image.asset(
                    'assets/images/kido_character.png',
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) =>
                        const Center(child: Text('🐘', style: TextStyle(fontSize: 24))),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0369A1),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0284C7),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'AI ADAPTIVE',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        message,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF334155),
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Row(
                        children: [
                          Text(
                            'Start AI Practice',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0284C7),
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_forward_rounded, size: 14, color: Color(0xFF0284C7)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
