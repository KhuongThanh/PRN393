import 'package:flutter/material.dart';

import '../../../core/mock/study_mock_data.dart';

class MatchScreen extends StatefulWidget {
  const MatchScreen({super.key, required this.setId});

  final String setId;

  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> {
  static const Color qDark = Color(0xFF2E3856);
  static const Color qGray = Color(0xFF939BB4);

  late final StudySetData set;
  late final List<StudyCardData> shuffledDefinitions;

  String? selectedTerm;
  String? selectedDefinition;
  final Set<String> matchedTerms = <String>{};
  int attempts = 0;

  @override
  void initState() {
    super.initState();
    set = StudyMockData.findSet(widget.setId);
    shuffledDefinitions = List<StudyCardData>.from(set.cards)..shuffle();
  }

  @override
  Widget build(BuildContext context) {
    final completed = matchedTerms.length == set.cards.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: qDark,
        elevation: 0,
        title: Text(
          'Match: ${set.title}',
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
          child: completed ? _buildSummary(context) : _buildBoard(),
        ),
      ),
    );
  }

  Widget _buildBoard() {
    final progress = matchedTerms.length / set.cards.length;

    return Column(
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
              '${matchedTerms.length}/${set.cards.length}',
              style: const TextStyle(
                fontSize: 12,
                color: qGray,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            children: [
              Expanded(
                child: _infoMetric(
                  label: 'Matched',
                  value: '${matchedTerms.length}',
                  color: const Color(0xFF1DB954),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _infoMetric(
                  label: 'Attempts',
                  value: '$attempts',
                  color: set.accentColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _infoMetric(label: 'Mode', value: 'Fast', color: qDark),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: _buildColumn(
                  title: 'Terms',
                  children: set.cards.map(_buildTermTile).toList(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildColumn(
                  title: 'Definitions',
                  children: shuffledDefinitions
                      .map(_buildDefinitionTile)
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildColumn({required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: qDark,
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: SingleChildScrollView(child: Column(children: children)),
          ),
        ],
      ),
    );
  }

  Widget _buildTermTile(StudyCardData card) {
    final isMatched = matchedTerms.contains(card.term);
    final isSelected = selectedTerm == card.term;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: isMatched
            ? null
            : () {
                setState(() => selectedTerm = card.term);
                _tryMatch();
              },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isMatched
                ? const Color(0xFFEFFFF5)
                : isSelected
                ? const Color(0xFFF0F2FF)
                : const Color(0xFFF8F9FE),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isMatched
                  ? const Color(0xFF1DB954)
                  : isSelected
                  ? set.accentColor
                  : Colors.transparent,
            ),
          ),
          child: Text(
            card.term,
            style: TextStyle(
              fontSize: 14,
              color: isMatched ? const Color(0xFF1DB954) : qDark,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDefinitionTile(StudyCardData card) {
    final isMatched = matchedTerms.contains(card.term);
    final isSelected = selectedDefinition == card.definition;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: isMatched
            ? null
            : () {
                setState(() => selectedDefinition = card.definition);
                _tryMatch();
              },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isMatched
                ? const Color(0xFFEFFFF5)
                : isSelected
                ? const Color(0xFFF0F2FF)
                : const Color(0xFFF8F9FE),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isMatched
                  ? const Color(0xFF1DB954)
                  : isSelected
                  ? set.accentColor
                  : Colors.transparent,
            ),
          ),
          child: Text(
            card.definition,
            style: TextStyle(
              fontSize: 13,
              color: isMatched ? const Color(0xFF1DB954) : qDark,
              fontWeight: FontWeight.w700,
              height: 1.4,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummary(BuildContext context) {
    return Column(
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
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: set.accentColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  Icons.grid_view_rounded,
                  size: 34,
                  color: set.accentColor,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Match finished',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: qDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You matched all ${set.cards.length} pairs in $attempts attempts.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: qGray, height: 1.5),
              ),
            ],
          ),
        ),
        const Spacer(),
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
                onPressed: _restart,
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
                  'Play again',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _infoMetric({
    required String label,
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
            label,
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
              fontSize: 18,
              color: color,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  void _tryMatch() {
    if (selectedTerm == null || selectedDefinition == null) {
      return;
    }

    attempts += 1;

    final card = set.cards.firstWhere((item) => item.term == selectedTerm);
    final isCorrect = card.definition == selectedDefinition;

    if (isCorrect) {
      setState(() {
        matchedTerms.add(card.term);
        selectedTerm = null;
        selectedDefinition = null;
      });
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    setState(() {
      selectedTerm = null;
      selectedDefinition = null;
    });
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Not this pair yet. Try another one.')),
      );
  }

  void _restart() {
    setState(() {
      matchedTerms.clear();
      selectedTerm = null;
      selectedDefinition = null;
      attempts = 0;
      shuffledDefinitions.shuffle();
    });
  }
}
