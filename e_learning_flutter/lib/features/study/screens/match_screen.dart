import 'package:flutter/material.dart';

import '../../../core/models/api_models.dart';
import '../../../core/services/study_api_service.dart';

class MatchScreen extends StatefulWidget {
  const MatchScreen({super.key, required this.setId});

  final String setId;

  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> {
  static const Color qDark = Color(0xFF2E3856);
  static const Color qGray = Color(0xFF939BB4);
  static const Color qBlue = Color(0xFF4255FF);

  final StudyApiService _studyApiService = StudyApiService();
  late Future<_MatchBundle> _matchFuture;

  String? _selectedWordId;
  String? _selectedMeaning;
  final Set<String> _matchedWordIds = <String>{};
  int _attempts = 0;

  @override
  void initState() {
    super.initState();
    _matchFuture = _loadData();
  }

  Future<_MatchBundle> _loadData() async {
    final topic = await _studyApiService.getTopic(widget.setId);
    final words = await _studyApiService.getWordsByTopic(widget.setId);
    final shuffled = List<WordItemData>.from(words)..shuffle();
    return _MatchBundle(topic: topic, words: words, shuffledWords: shuffled);
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
          'Match',
          style: TextStyle(
            color: qDark,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: SafeArea(
        child: FutureBuilder<_MatchBundle>(
          future: _matchFuture,
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

            final completed = _matchedWordIds.length == data.words.length;

            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
              child: completed ? _buildSummary(data) : _buildBoard(data),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBoard(_MatchBundle data) {
    final progress = _matchedWordIds.length / data.words.length;

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
                  valueColor: const AlwaysStoppedAnimation<Color>(qBlue),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '${_matchedWordIds.length}/${data.words.length}',
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
                child: _metric(
                  'Matched',
                  '${_matchedWordIds.length}',
                  const Color(0xFF1DB954),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: _metric('Attempts', '$_attempts', qBlue)),
              const SizedBox(width: 12),
              Expanded(child: _metric('Topic', '${data.words.length}', qDark)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: _buildColumn(
                  'Words',
                  data.words
                      .map((word) => _buildWordTile(word.wordId, word.wordText))
                      .toList(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildColumn(
                  'Meanings',
                  data.shuffledWords
                      .map(
                        (word) => _buildMeaningTile(word.wordId, word.meaning),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildColumn(String title, List<Widget> children) {
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
              color: qDark,
              fontWeight: FontWeight.w900,
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

  Widget _buildWordTile(String wordId, String wordText) {
    final isMatched = _matchedWordIds.contains(wordId);
    final isSelected = _selectedWordId == wordId;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: isMatched
            ? null
            : () {
                setState(() => _selectedWordId = wordId);
                _tryMatch();
              },
        child: Container(
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
                  ? qBlue
                  : Colors.transparent,
            ),
          ),
          child: Text(
            wordText,
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

  Widget _buildMeaningTile(String wordId, String meaning) {
    final isMatched = _matchedWordIds.contains(wordId);
    final isSelected = _selectedMeaning == meaning;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: isMatched
            ? null
            : () {
                setState(() => _selectedMeaning = meaning);
                _tryMatch();
              },
        child: Container(
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
                  ? qBlue
                  : Colors.transparent,
            ),
          ),
          child: Text(
            meaning,
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

  Widget _buildSummary(_MatchBundle data) {
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
                  Icons.grid_view_rounded,
                  size: 34,
                  color: qBlue,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Match complete',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: qDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You matched ${data.words.length} API-loaded word pairs in $_attempts attempts.',
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
                    _matchedWordIds.clear();
                    _selectedWordId = null;
                    _selectedMeaning = null;
                    _attempts = 0;
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

  Widget _metric(String label, String value, Color color) {
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
              'Unable to load match data',
              style: TextStyle(
                fontSize: 22,
                color: qDark,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'The app could not fetch topic words from the API for match mode.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: qGray, height: 1.5),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: () {
                setState(() => _matchFuture = _loadData());
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
            Icon(Icons.grid_view_rounded, size: 42, color: qBlue),
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
              'This topic does not have any vocabulary words to match yet.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: qGray, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  void _tryMatch() {
    if (_selectedWordId == null || _selectedMeaning == null) {
      return;
    }

    _attempts += 1;

    final bundle = _matchFuture;
    bundle.then((data) {
      final selectedWord = data.words.firstWhere(
        (word) => word.wordId == _selectedWordId,
      );
      final correct = selectedWord.meaning == _selectedMeaning;

      if (!mounted) {
        return;
      }

      if (correct) {
        setState(() {
          _matchedWordIds.add(selectedWord.wordId);
          _selectedWordId = null;
          _selectedMeaning = null;
        });
        return;
      }

      setState(() {
        _selectedWordId = null;
        _selectedMeaning = null;
      });
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Not this pair yet. Try another one.')),
        );
    });
  }
}

class _MatchBundle {
  const _MatchBundle({
    required this.topic,
    required this.words,
    required this.shuffledWords,
  });

  final TopicSummaryData topic;
  final List<WordItemData> words;
  final List<WordItemData> shuffledWords;
}
