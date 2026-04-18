import 'package:flutter/material.dart';

import '../../../core/mock/study_mock_data.dart';

class FlashcardScreen extends StatefulWidget {
  const FlashcardScreen({super.key, required this.setId});

  final String setId;

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  static const Color qDark = Color(0xFF2E3856);
  static const Color qGray = Color(0xFF939BB4);

  int currentIndex = 0;
  int knownCount = 0;
  int reviewCount = 0;
  bool showBack = false;

  @override
  Widget build(BuildContext context) {
    final set = StudyMockData.findSet(widget.setId);
    final completed = currentIndex >= set.cards.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: qDark,
        elevation: 0,
        title: Text(
          set.title,
          style: const TextStyle(
            color: qDark,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
          child: completed ? _buildSummary(context, set) : _buildSession(set),
        ),
      ),
    );
  }

  Widget _buildSession(StudySetData set) {
    final card = set.cards[currentIndex];
    final progress = (currentIndex + 1) / set.cards.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  minHeight: 10,
                  value: progress,
                  backgroundColor: const Color(0xFFECEEF5),
                  valueColor: AlwaysStoppedAnimation<Color>(set.accentColor),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '${currentIndex + 1}/${set.cards.length}',
              style: const TextStyle(
                fontSize: 12,
                color: qGray,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            _miniStat('Known', '$knownCount', const Color(0xFF1DB954)),
            const SizedBox(width: 10),
            _miniStat('Review', '$reviewCount', set.accentColor),
          ],
        ),
        const SizedBox(height: 18),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => showBack = !showBack),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: set.accentColor.withValues(alpha: 0.12),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: set.accentColor.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          showBack ? 'Definition' : 'Term',
                          style: TextStyle(
                            fontSize: 11,
                            color: set.accentColor,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.touch_app_outlined,
                        size: 18,
                        color: qGray.withValues(alpha: 0.8),
                      ),
                    ],
                  ),
                  const Spacer(),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    child: Text(
                      showBack ? card.definition : card.term,
                      key: ValueKey<bool>(showBack),
                      style: const TextStyle(
                        fontSize: 30,
                        height: 1.2,
                        color: qDark,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    showBack ? card.example : 'Tap card to reveal the answer',
                    style: const TextStyle(
                      fontSize: 13,
                      color: qGray,
                      height: 1.5,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FE),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.lightbulb_outline, color: set.accentColor),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Use Flashcards first, then move to Match or Write for stronger recall.',
                            style: TextStyle(
                              fontSize: 12,
                              color: qDark.withValues(alpha: 0.85),
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => showBack = !showBack),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(54),
                  side: BorderSide(
                    color: set.accentColor.withValues(alpha: 0.18),
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  showBack ? 'Show term' : 'Reveal answer',
                  style: TextStyle(
                    color: set.accentColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: showBack ? _markReview : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFF2F2),
                  foregroundColor: const Color(0xFFFF6B6B),
                  minimumSize: const Size.fromHeight(54),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Review again',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: showBack ? _markKnown : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: set.accentColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(54),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'I know this',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummary(BuildContext context, StudySetData set) {
    final total = set.cards.length;
    final accuracy = total == 0 ? 0 : ((knownCount / total) * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: set.accentColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(24),
                ),
                alignment: Alignment.center,
                child: Text(set.emoji, style: const TextStyle(fontSize: 34)),
              ),
              const SizedBox(height: 18),
              const Text(
                'Flashcards completed',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: qDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You reviewed $total cards in ${set.title}.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: qGray, height: 1.5),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _summaryCard(
                      title: 'Known',
                      value: '$knownCount',
                      color: const Color(0xFF1DB954),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _summaryCard(
                      title: 'Need review',
                      value: '$reviewCount',
                      color: set.accentColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _summaryCard(
                      title: 'Accuracy',
                      value: '$accuracy%',
                      color: qDark,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Back to set',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    currentIndex = 0;
                    knownCount = 0;
                    reviewCount = 0;
                    showBack = false;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: set.accentColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(54),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Restart',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _miniStat(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: qGray,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: color,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard({
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FE),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              color: qGray,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              color: color,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  void _markKnown() {
    setState(() {
      knownCount += 1;
      currentIndex += 1;
      showBack = false;
    });
  }

  void _markReview() {
    setState(() {
      reviewCount += 1;
      currentIndex += 1;
      showBack = false;
    });
  }
}
