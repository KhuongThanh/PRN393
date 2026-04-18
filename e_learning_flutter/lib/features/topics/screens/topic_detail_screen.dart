import 'package:flutter/material.dart';

import '../../../core/mock/study_mock_data.dart';

class TopicDetailScreen extends StatelessWidget {
  const TopicDetailScreen({super.key, required this.setId});

  final String setId;

  static const Color qBlue = Color(0xFF4255FF);
  static const Color qDark = Color(0xFF2E3856);
  static const Color qGray = Color(0xFF939BB4);

  @override
  Widget build(BuildContext context) {
    final set = StudyMockData.findSet(setId);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHero(context, set),
              _buildSummary(set),
              _buildModes(context, set),
              _buildTermList(set),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHero(BuildContext context, StudySetData set) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [set.accentColor, qDark],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _roundButton(
                icon: Icons.arrow_back,
                onTap: () => Navigator.pop(context),
              ),
              const Spacer(),
              _roundButton(icon: Icons.ios_share_outlined, onTap: () {}),
              const SizedBox(width: 8),
              _roundButton(icon: Icons.more_horiz, onTap: () {}),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(18),
            ),
            alignment: Alignment.center,
            child: Text(set.emoji, style: const TextStyle(fontSize: 30)),
          ),
          const SizedBox(height: 18),
          Text(
            set.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            set.description,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _infoChip('${set.termCount} terms'),
              _infoChip('${(set.learnedPercent * 100).round()}% mastered'),
              _infoChip('by ${set.author}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummary(StudySetData set) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _statCard(
                  title: 'Learned',
                  value: '${set.learnedCount}',
                  subtitle: 'cards ready',
                  color: const Color(0xFF1DB954),
                  icon: Icons.check_circle_outline,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _statCard(
                  title: 'Review',
                  value: '${set.termCount - set.learnedCount}',
                  subtitle: 'cards pending',
                  color: set.accentColor,
                  icon: Icons.refresh_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Progress',
              style: TextStyle(
                color: qDark.withValues(alpha: 0.85),
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 10,
              value: set.learnedPercent,
              backgroundColor: const Color(0xFFECEEF5),
              valueColor: AlwaysStoppedAnimation<Color>(set.accentColor),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '${set.learnedCount}/${set.termCount} cards studied',
                style: const TextStyle(fontSize: 12, color: qGray),
              ),
              const Spacer(),
              Wrap(
                spacing: 6,
                children: set.tags
                    .map(
                      (tag) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F2FF),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          tag,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: qBlue,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModes(BuildContext context, StudySetData set) {
    final actions = [
      (
        label: 'Flashcards',
        icon: Icons.style_outlined,
        color: set.accentColor,
        bg: set.accentColor.withValues(alpha: 0.10),
        route: '/flashcard/${set.id}',
      ),
      (
        label: 'Test',
        icon: Icons.fact_check_outlined,
        color: const Color(0xFFC8970A),
        bg: const Color(0xFFFFF6D8),
        route: '/quiz/${set.id}',
      ),
      (
        label: 'Match',
        icon: Icons.grid_view_rounded,
        color: const Color(0xFF1DB954),
        bg: const Color(0xFFEFFFF5),
        route: '/match/${set.id}',
      ),
      (
        label: 'Write',
        icon: Icons.edit_note_outlined,
        color: const Color(0xFFFF6B6B),
        bg: const Color(0xFFFFF2F2),
        route: '/write/${set.id}',
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Study modes',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: qDark,
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: actions.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.6,
            ),
            itemBuilder: (context, index) {
              final action = actions[index];
              return GestureDetector(
                onTap: () => Navigator.pushNamed(context, action.route),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: action.bg,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: action.color.withValues(alpha: 0.18),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(action.icon, color: action.color),
                      const Spacer(),
                      Text(
                        action.label,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: action.color,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Start session',
                        style: TextStyle(fontSize: 11, color: qGray),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTermList(StudySetData set) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Terms in this set',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: qDark,
            ),
          ),
          const SizedBox(height: 12),
          ...List.generate(set.cards.length, (index) {
            final card = set.cards[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: set.accentColor.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: set.accentColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          card.term,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: qDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          card.definition,
                          style: const TextStyle(
                            fontSize: 13,
                            color: qDark,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          card.example,
                          style: const TextStyle(
                            fontSize: 12,
                            color: qGray,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _roundButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, size: 20, color: Colors.white),
      ),
    );
  }

  Widget _infoChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _statCard({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FE),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: qGray,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              color: color,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(subtitle, style: const TextStyle(fontSize: 11, color: qGray)),
        ],
      ),
    );
  }
}
