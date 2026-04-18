import 'package:flutter/material.dart';

import '../../../core/mock/study_mock_data.dart';

class WriteScreen extends StatefulWidget {
  const WriteScreen({super.key, required this.setId});

  final String setId;

  @override
  State<WriteScreen> createState() => _WriteScreenState();
}

class _WriteScreenState extends State<WriteScreen> {
  static const Color qBlue = Color(0xFF4255FF);
  static const Color qDark = Color(0xFF2E3856);
  static const Color qGray = Color(0xFF939BB4);

  final TextEditingController answerController = TextEditingController();

  int currentIndex = 0;
  int correctCount = 0;
  bool checked = false;
  bool isCorrect = false;

  @override
  void dispose() {
    answerController.dispose();
    super.dispose();
  }

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
          'Write: ${set.title}',
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
          child: completed ? _buildSummary(context, set) : _buildPrompt(set),
        ),
      ),
    );
  }

  Widget _buildPrompt(StudySetData set) {
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
          padding: const EdgeInsets.all(22),
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
                  'Type the correct term',
                  style: TextStyle(
                    fontSize: 11,
                    color: qBlue,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                card.definition,
                style: const TextStyle(
                  fontSize: 25,
                  color: qDark,
                  fontWeight: FontWeight.w900,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                card.example,
                style: const TextStyle(fontSize: 13, color: qGray, height: 1.5),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: answerController,
                enabled: !checked,
                onSubmitted: (_) => checked ? _next() : _checkAnswer(set),
                decoration: InputDecoration(
                  hintText: 'Type your answer here',
                  filled: true,
                  fillColor: const Color(0xFFF8F9FE),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              if (checked) ...[
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isCorrect
                        ? const Color(0xFFEFFFF5)
                        : const Color(0xFFFFF2F2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isCorrect
                          ? const Color(0xFF1DB954)
                          : const Color(0xFFFF6B6B),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isCorrect ? 'Correct answer' : 'Keep practicing',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: isCorrect
                              ? const Color(0xFF1DB954)
                              : const Color(0xFFFF6B6B),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Expected term: ${card.term}',
                        style: const TextStyle(fontSize: 12, color: qDark),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: checked ? _next : () => _checkAnswer(set),
            style: ElevatedButton.styleFrom(
              backgroundColor: qBlue,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(54),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              checked
                  ? (currentIndex == set.cards.length - 1
                        ? 'Finish write mode'
                        : 'Next card')
                  : 'Check answer',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummary(BuildContext context, StudySetData set) {
    final total = set.cards.length;
    final accuracy = total == 0 ? 0 : ((correctCount / total) * 100).round();

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
                  Icons.edit_note_outlined,
                  size: 36,
                  color: qBlue,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Write session done',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: qDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You wrote $correctCount correct answers with $accuracy% accuracy.',
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
                  backgroundColor: qBlue,
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

  void _checkAnswer(StudySetData set) {
    final answer = answerController.text.trim().toLowerCase();
    final expected = set.cards[currentIndex].term.trim().toLowerCase();
    final correct = answer == expected;

    setState(() {
      checked = true;
      isCorrect = correct;
      if (correct) {
        correctCount += 1;
      }
    });
  }

  void _next() {
    setState(() {
      currentIndex += 1;
      checked = false;
      isCorrect = false;
      answerController.clear();
    });
  }

  void _restart() {
    setState(() {
      currentIndex = 0;
      correctCount = 0;
      checked = false;
      isCorrect = false;
      answerController.clear();
    });
  }
}
