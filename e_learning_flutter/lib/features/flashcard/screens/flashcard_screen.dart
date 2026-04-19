import 'package:flutter/material.dart';

import '../../../core/models/api_models.dart';
import '../../../core/services/study_api_service.dart';
import '../../../core/services/study_sync_service.dart';

class FlashcardScreen extends StatefulWidget {
  const FlashcardScreen({super.key, required this.setId});

  final String setId;

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  static const Color qBlue = Color(0xFF4255FF);
  static const Color qDark = Color(0xFF2E3856);
  static const Color qGray = Color(0xFF939BB4);

  final StudyApiService _studyApiService = StudyApiService();

  FlashcardSessionStartData? _session;
  FlashcardFinishData? _summary;
  String? _errorMessage;
  bool _loading = true;
  bool _submitting = false;
  bool _showBack = false;
  int _currentIndex = 0;
  int _rememberedCount = 0;
  int _notRememberedCount = 0;
  final Set<String> _favoriteWordIds = <String>{};
  final Set<String> _favoriteLoadingIds = <String>{};

  @override
  void initState() {
    super.initState();
    _startSession();
  }

  @override
  Widget build(BuildContext context) {
    final session = _session;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: qDark,
        elevation: 0,
        title: Text(
          session?.topicName ?? 'Flashcards',
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
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (_summary != null) {
      return _buildSummary();
    }

    final session = _session;
    if (session == null || session.words.isEmpty) {
      return _buildEmptyState();
    }

    final card = session.words[_currentIndex];
    final progress = (_currentIndex + 1) / session.words.length;

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
              '${_currentIndex + 1}/${session.words.length}',
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
            _miniStat(
              'Remembered',
              '$_rememberedCount',
              const Color(0xFF1DB954),
            ),
            const SizedBox(width: 10),
            _miniStat(
              'Review again',
              '$_notRememberedCount',
              const Color(0xFFFF6B6B),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _showBack = !_showBack),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
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
                          color: const Color(0xFFF0F2FF),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          _showBack ? 'Meaning' : 'Word',
                          style: const TextStyle(
                            fontSize: 11,
                            color: qBlue,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const Spacer(),
                      _favoriteButton(
                        wordId: card.wordId,
                        label: card.wordText,
                      ),
                      const SizedBox(width: 10),
                      const Icon(
                        Icons.touch_app_outlined,
                        size: 18,
                        color: qGray,
                      ),
                    ],
                  ),
                  const Spacer(),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    child: Text(
                      _showBack ? card.meaning : card.wordText,
                      key: ValueKey<bool>(_showBack),
                      style: const TextStyle(
                        fontSize: 30,
                        height: 1.2,
                        color: qDark,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _showBack
                        ? (card.exampleSentence?.trim().isNotEmpty == true
                              ? card.exampleSentence!
                              : 'No example sentence available.')
                        : 'Tap the card to reveal the meaning.',
                    style: const TextStyle(
                      fontSize: 13,
                      color: qGray,
                      height: 1.5,
                    ),
                  ),
                  const Spacer(),
                  if (card.partOfSpeech?.trim().isNotEmpty == true ||
                      card.phonetic?.trim().isNotEmpty == true)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (card.partOfSpeech?.trim().isNotEmpty == true)
                          _tag(card.partOfSpeech!),
                        if (card.phonetic?.trim().isNotEmpty == true)
                          _tag(card.phonetic!),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _submitting
                ? null
                : () => setState(() => _showBack = !_showBack),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(54),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              _showBack ? 'Show word' : 'Reveal meaning',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _submitting || !_showBack
                    ? null
                    : () => _reviewCurrent(false),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFF2F2),
                  foregroundColor: const Color(0xFFFF6B6B),
                  minimumSize: const Size.fromHeight(54),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _submitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Review again',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _submitting || !_showBack
                    ? null
                    : () => _reviewCurrent(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4255FF),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(54),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _submitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text(
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

  Widget _buildSummary() {
    final summary = _summary!;
    final percent = (summary.completionRate * 100).round();

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
                  size: 36,
                  color: Color(0xFF4255FF),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Flashcard session finished',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: qDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'The session was saved to the backend with $percent% completion.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: qGray, height: 1.5),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _summaryMetric(
                      'Remembered',
                      '${summary.rememberedCount}',
                      const Color(0xFF1DB954),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _summaryMetric(
                      'Review again',
                      '${summary.notRememberedCount}',
                      const Color(0xFFFF6B6B),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _summaryMetric(
                      'Duration',
                      '${summary.durationSeconds}s',
                      const Color(0xFF4255FF),
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
                onPressed: _startSession,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4255FF),
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

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              size: 42,
              color: Color(0xFF4255FF),
            ),
            const SizedBox(height: 12),
            const Text(
              'Unable to start flashcard session',
              style: TextStyle(
                fontSize: 22,
                color: qDark,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'The API request failed.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: qGray, height: 1.5),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: _startSession,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4255FF),
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

  Widget _favoriteButton({required String wordId, required String label}) {
    final isFavorite = _favoriteWordIds.contains(wordId);
    final isUpdating = _favoriteLoadingIds.contains(wordId);

    return GestureDetector(
      onTap: isUpdating ? null : () => _toggleFavorite(wordId, label),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: isFavorite ? const Color(0xFFFFF2F2) : const Color(0xFFF8F9FE),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: isUpdating
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? const Color(0xFFFF6B6B) : qGray,
                size: 18,
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
            Icon(Icons.style_outlined, size: 42, color: Color(0xFF4255FF)),
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
              'The study session started successfully but did not return any words.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: qGray, height: 1.5),
            ),
          ],
        ),
      ),
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

  Widget _summaryMetric(String title, String value, Color color) {
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

  Widget _tag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F2FF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          color: Color(0xFF4255FF),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Future<void> _startSession() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
      _summary = null;
      _session = null;
      _currentIndex = 0;
      _rememberedCount = 0;
      _notRememberedCount = 0;
      _showBack = false;
      _favoriteWordIds.clear();
      _favoriteLoadingIds.clear();
    });

    try {
      final session = await _studyApiService.startFlashcardSession(
        topicId: widget.setId,
      );
      Set<String> favoriteWordIds = <String>{};
      try {
        final favorites = await _studyApiService.getFavorites();
        favoriteWordIds = favorites.map((item) => item.wordId).toSet();
      } catch (_) {
        favoriteWordIds = <String>{};
      }
      if (!mounted) {
        return;
      }
      setState(() {
        _session = session;
        _favoriteWordIds
          ..clear()
          ..addAll(favoriteWordIds);
        _loading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _reviewCurrent(bool remembered) async {
    final session = _session;
    if (session == null || _submitting) {
      return;
    }

    final card = session.words[_currentIndex];

    setState(() => _submitting = true);

    try {
      final review = await _studyApiService.reviewFlashcard(
        sessionId: session.sessionId,
        wordId: card.wordId,
        isRemembered: remembered,
        reviewOrder: _currentIndex + 1,
      );

      if (review.isCompleted || _currentIndex >= session.words.length - 1) {
        final summary = await _studyApiService.finishFlashcardSession(
          session.sessionId,
        );
        if (!mounted) {
          return;
        }
        setState(() {
          _summary = summary;
          _rememberedCount = review.rememberedCount;
          _notRememberedCount = review.notRememberedCount;
          _submitting = false;
        });
        return;
      }

      if (!mounted) {
        return;
      }
      setState(() {
        _rememberedCount = review.rememberedCount;
        _notRememberedCount = review.notRememberedCount;
        _currentIndex += 1;
        _showBack = false;
        _submitting = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _submitting = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _toggleFavorite(String wordId, String label) async {
    if (_favoriteLoadingIds.contains(wordId)) {
      return;
    }

    final wasFavorite = _favoriteWordIds.contains(wordId);
    setState(() {
      _favoriteLoadingIds.add(wordId);
      if (wasFavorite) {
        _favoriteWordIds.remove(wordId);
      } else {
        _favoriteWordIds.add(wordId);
      }
    });

    try {
      if (wasFavorite) {
        await _studyApiService.removeFavorite(wordId);
      } else {
        await _studyApiService.addFavorite(wordId);
      }

      if (!mounted) {
        return;
      }
      StudySyncService.instance.notifyFavoriteChanged(
        wordId: wordId,
        isFavorite: !wasFavorite,
      );
      _showMessage(
        wasFavorite
            ? '"$label" was removed from favorites.'
            : '"$label" was added to favorites.',
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        if (wasFavorite) {
          _favoriteWordIds.add(wordId);
        } else {
          _favoriteWordIds.remove(wordId);
        }
      });
      _showMessage(
        _errorText(error, fallback: 'Unable to update favorites right now.'),
      );
    } finally {
      if (mounted) {
        setState(() => _favoriteLoadingIds.remove(wordId));
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String _errorText(Object error, {required String fallback}) {
    if (error is ApiException && error.message.trim().isNotEmpty) {
      return error.message;
    }
    return fallback;
  }
}
