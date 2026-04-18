import 'package:flutter/material.dart';

import '../../../core/mock/study_mock_data.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key, required this.setId});

  final String setId;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  static const Color qBlue = Color(0xFF4255FF);
  static const Color qDark = Color(0xFF2E3856);
  static const Color qGray = Color(0xFF939BB4);

  int currentIndex = 0;
  int score = 0;
  String? selectedOption;
  bool answered = false;

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
          'Test: ${set.title}',
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
          child: completed ? _buildSummary(context, set) : _buildQuestion(set),
        ),
      ),
    );
  }

  Widget _buildQuestion(StudySetData set) {
    final question = set.cards[currentIndex];
    final options = StudyMockData.buildQuizOptions(set, currentIndex);
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
                  valueColor: const AlwaysStoppedAnimation<Color>(qBlue),
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
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F2FF),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'Choose the correct term',
                  style: TextStyle(
                    fontSize: 11,
                    color: qBlue,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                question.definition,
                style: const TextStyle(
                  fontSize: 26,
                  color: qDark,
                  fontWeight: FontWeight.w900,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                question.example,
                style: const TextStyle(fontSize: 13, color: qGray, height: 1.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...options.map((option) => _buildOptionTile(question.term, option)),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: answered ? _goNext : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: qBlue,
              foregroundColor: Colors.white,
              disabledBackgroundColor: const Color(0xFFC7CFFE),
              minimumSize: const Size.fromHeight(54),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              currentIndex == set.cards.length - 1 ? 'Finish quiz' : 'Continue',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOptionTile(String correctTerm, String optionDefinition) {
    final isSelected = selectedOption == optionDefinition;
    final isCorrect = optionDefinition == _definitionFor(correctTerm);
    final showCorrect = answered && isCorrect;
    final showWrong = answered && isSelected && !isCorrect;

    Color borderColor = const Color(0xFFECEEF5);
    Color fillColor = Colors.white;

    if (showCorrect) {
      borderColor = const Color(0xFF1DB954);
      fillColor = const Color(0xFFEFFFF5);
    } else if (showWrong) {
      borderColor = const Color(0xFFFF6B6B);
      fillColor = const Color(0xFFFFF2F2);
    } else if (isSelected) {
      borderColor = qBlue;
      fillColor = const Color(0xFFF0F2FF);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: answered
            ? null
            : () {
                final correct = optionDefinition == _definitionFor(correctTerm);
                setState(() {
                  selectedOption = optionDefinition;
                  answered = true;
                  if (correct) {
                    score += 1;
                  }
                });
              },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: fillColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor, width: 1.5),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _termForDefinition(optionDefinition),
                  style: const TextStyle(
                    fontSize: 15,
                    color: qDark,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (showCorrect)
                const Icon(Icons.check_circle, color: Color(0xFF1DB954))
              else if (showWrong)
                const Icon(Icons.cancel, color: Color(0xFFFF6B6B)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummary(BuildContext context, StudySetData set) {
    final total = set.cards.length;
    final percent = total == 0 ? 0 : ((score / total) * 100).round();

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
                  color: const Color(0xFFF0F2FF),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.emoji_events_outlined,
                  size: 34,
                  color: qBlue,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Quiz complete',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: qDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You answered $score out of $total questions correctly.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: qGray, height: 1.5),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: _resultStat('Score', '$score/$total')),
                  const SizedBox(width: 12),
                  Expanded(child: _resultStat('Accuracy', '$percent%')),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _resultStat(
                      'Level',
                      percent >= 80 ? 'Strong' : 'Keep going',
                    ),
                  ),
                ],
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
                onPressed: () {
                  setState(() {
                    currentIndex = 0;
                    score = 0;
                    selectedOption = null;
                    answered = false;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: qBlue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(54),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Try again',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _resultStat(String label, String value) {
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
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              color: qDark,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  String _definitionFor(String term) {
    final set = StudyMockData.findSet(widget.setId);
    return set.cards.firstWhere((card) => card.term == term).definition;
  }

  String _termForDefinition(String definition) {
    final set = StudyMockData.findSet(widget.setId);
    for (final card in set.cards) {
      if (card.definition == definition) {
        return card.term;
      }
    }
    return definition;
  }

  void _goNext() {
    setState(() {
      currentIndex += 1;
      selectedOption = null;
      answered = false;
    });
  }
}
