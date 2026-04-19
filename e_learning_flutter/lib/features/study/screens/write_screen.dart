import 'package:flutter/material.dart';

import '../../../core/models/api_models.dart';
import '../../../core/services/study_api_service.dart';

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

  final StudyApiService _studyApiService = StudyApiService();
  final TextEditingController _answerController = TextEditingController();
  late Future<_WriteBundle> _writeFuture;

  int _currentIndex = 0;
  int _correctCount = 0;
  bool _checked = false;
  bool _isCorrect = false;

  @override
  void initState() {
    super.initState();
    _writeFuture = _loadData();
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  Future<_WriteBundle> _loadData() async {
    final topic = await _studyApiService.getTopic(widget.setId);
    final words = await _studyApiService.getWordsByTopic(widget.setId);
    return _WriteBundle(topic: topic, words: words);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: qDark,
        elevation: 0,
        title: const Text(
          'Write',
          style: TextStyle(
            color: qDark,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: SafeArea(
        child: FutureBuilder<_WriteBundle>(
          future: _writeFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError || !snapshot.hasData) {
              return _buildErrorState();
            }

            final data = snapshot.data!;
            if (data.words.isEmpty) {
              return _buildEmptyState();
            }

            final completed = _currentIndex >= data.words.length;

            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
              child: completed ? _buildSummary(data) : _buildPrompt(data),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPrompt(_WriteBundle data) {
    final word = data.words[_currentIndex];
    final progress = (_currentIndex + 1) / data.words.length;

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
              '${_currentIndex + 1}/${data.words.length}',
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
                  'Type the correct word',
                  style: TextStyle(
                    fontSize: 11,
                    color: qBlue,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                word.meaning,
                style: const TextStyle(
                  fontSize: 25,
                  color: qDark,
                  fontWeight: FontWeight.w900,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                word.partOfSpeech?.trim().isNotEmpty == true
                    ? 'Part of speech: ${word.partOfSpeech}'
                    : 'Use your memory to type the matching word.',
                style: const TextStyle(fontSize: 13, color: qGray),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: _answerController,
                enabled: !_checked,
                onSubmitted: (_) =>
                    _checked ? _next(data.words.length) : _check(word),
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
              if (_checked) ...[
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _isCorrect
                        ? const Color(0xFFEFFFF5)
                        : const Color(0xFFFFF2F2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    _isCorrect
                        ? 'Correct! The API word matched your answer.'
                        : 'Expected answer: ${word.wordText}',
                    style: TextStyle(
                      fontSize: 12,
                      color: _isCorrect
                          ? const Color(0xFF1DB954)
                          : const Color(0xFFFF6B6B),
                      fontWeight: FontWeight.w800,
                    ),
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
            onPressed: () => _checked ? _next(data.words.length) : _check(word),
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
              _checked
                  ? (_currentIndex == data.words.length - 1
                        ? 'Finish write mode'
                        : 'Next word')
                  : 'Check answer',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummary(_WriteBundle data) {
    final accuracy = ((_correctCount / data.words.length) * 100).round();

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
                'You typed $_correctCount correct answers from ${data.words.length} words loaded by the API.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: qGray, height: 1.5),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(child: _metric('Correct', '$_correctCount', qBlue)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _metric(
                      'Accuracy',
                      '$accuracy%',
                      const Color(0xFF1DB954),
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
                  'Back to topic',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _currentIndex = 0;
                    _correctCount = 0;
                    _checked = false;
                    _isCorrect = false;
                    _answerController.clear();
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

  Widget _metric(String title, String value, Color color) {
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
              fontSize: 20,
              color: color,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 42, color: qBlue),
            const SizedBox(height: 12),
            const Text(
              'Unable to load write mode',
              style: TextStyle(
                fontSize: 22,
                color: qDark,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'The app could not fetch topic words from the API for write mode.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: qGray, height: 1.5),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: () {
                setState(() => _writeFuture = _loadData());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: qBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Try again',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.edit_note_outlined, size: 42, color: qBlue),
            SizedBox(height: 12),
            Text(
              'No words available',
              style: TextStyle(
                fontSize: 22,
                color: qDark,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'This topic does not have any vocabulary words to practice with.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: qGray, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  void _check(WordItemData word) {
    final answer = _answerController.text.trim().toLowerCase();
    final expected = word.wordText.trim().toLowerCase();
    final correct = answer == expected;

    setState(() {
      _checked = true;
      _isCorrect = correct;
      if (correct) {
        _correctCount += 1;
      }
    });
  }

  void _next(int totalWords) {
    if (_currentIndex >= totalWords - 1) {
      setState(() {
        _currentIndex = totalWords;
      });
      return;
    }

    setState(() {
      _currentIndex += 1;
      _checked = false;
      _isCorrect = false;
      _answerController.clear();
    });
  }
}

class _WriteBundle {
  const _WriteBundle({required this.topic, required this.words});

  final TopicSummaryData topic;
  final List<WordItemData> words;
}
