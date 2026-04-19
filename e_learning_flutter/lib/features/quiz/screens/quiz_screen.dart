import 'package:flutter/material.dart';

import '../../../core/models/api_models.dart';
import '../../../core/services/study_api_service.dart';
import '../../../core/services/study_sync_service.dart';

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

  final StudyApiService _studyApiService = StudyApiService();

  QuizAttemptStartData? _attempt;
  List<QuizQuestionData> _questions = const [];
  QuizSubmitResultData? _summary;
  String? _errorMessage;
  bool _loading = true;
  bool _submitting = false;
  int _currentIndex = 0;
  String? _selectedOptionId;
  bool _answered = false;
  bool _lastAnswerCorrect = false;
  final Set<String> _favoriteWordIds = <String>{};
  final Set<String> _favoriteLoadingIds = <String>{};

  @override
  void initState() {
    super.initState();
    _loadQuiz();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: qDark,
        elevation: 0,
        title: Text(
          _attempt?.quizTitle ?? 'Quiz',
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

    if (_questions.isEmpty) {
      return _buildEmptyState();
    }

    final question = _questions[_currentIndex];
    final progress = (_currentIndex + 1) / _questions.length;
    final questionWordId = question.wordId;

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
              '${_currentIndex + 1}/${_questions.length}',
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
                    child: const Text(
                      'Question from API',
                      style: TextStyle(
                        fontSize: 11,
                        color: qBlue,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (questionWordId != null)
                    _favoriteButton(
                      wordId: questionWordId,
                      label: question.questionText,
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                question.questionText,
                style: const TextStyle(
                  fontSize: 26,
                  color: qDark,
                  fontWeight: FontWeight.w900,
                  height: 1.2,
                ),
              ),
              if (_answered) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _lastAnswerCorrect
                        ? const Color(0xFFEFFFF5)
                        : const Color(0xFFFFF2F2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    _lastAnswerCorrect
                        ? 'Correct answer saved to the backend.'
                        : 'Answer saved. This one was not correct.',
                    style: TextStyle(
                      fontSize: 12,
                      color: _lastAnswerCorrect
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
        const SizedBox(height: 16),
        ...question.options.map(_buildOptionTile),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: !_answered || _submitting ? null : _goNext,
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
            child: _submitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    _currentIndex == _questions.length - 1
                        ? 'Finish quiz'
                        : 'Continue',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildOptionTile(QuizQuestionOptionData option) {
    final isSelected = _selectedOptionId == option.optionId;
    final fillColor = _answered
        ? (_lastAnswerCorrect && isSelected
              ? const Color(0xFFEFFFF5)
              : (!_lastAnswerCorrect && isSelected
                    ? const Color(0xFFFFF2F2)
                    : Colors.white))
        : (isSelected ? const Color(0xFFF0F2FF) : Colors.white);

    final borderColor = _answered
        ? (_lastAnswerCorrect && isSelected
              ? const Color(0xFF1DB954)
              : (!_lastAnswerCorrect && isSelected
                    ? const Color(0xFFFF6B6B)
                    : const Color(0xFFECEEF5)))
        : (isSelected ? qBlue : const Color(0xFFECEEF5));

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: _answered || _submitting
            ? null
            : () => _submitAnswer(option.optionId),
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
                  option.optionText,
                  style: const TextStyle(
                    fontSize: 14,
                    color: qDark,
                    fontWeight: FontWeight.w800,
                    height: 1.5,
                  ),
                ),
              ),
              if (_answered && isSelected)
                Icon(
                  _lastAnswerCorrect ? Icons.check_circle : Icons.cancel,
                  color: _lastAnswerCorrect
                      ? const Color(0xFF1DB954)
                      : const Color(0xFFFF6B6B),
                ),
            ],
          ),
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

  Widget _buildSummary() {
    final summary = _summary!;
    final percent = (summary.score * 100).round();

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
                  Icons.fact_check_outlined,
                  size: 36,
                  color: qBlue,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Quiz submitted',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: qDark,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'The quiz result was submitted through the API.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: qGray, height: 1.5),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _summaryMetric(
                      'Correct',
                      '${summary.correctAnswers}/${summary.totalQuestions}',
                      qBlue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _summaryMetric(
                      'Score',
                      '$percent%',
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
                onPressed: _loadQuiz,
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

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.quiz_outlined, size: 42, color: qBlue),
            SizedBox(height: 12),
            Text(
              'No quiz available',
              style: TextStyle(
                fontSize: 22,
                color: qDark,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'The selected topic does not have an active quiz yet.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: qGray, height: 1.5),
            ),
          ],
        ),
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
              'Unable to load quiz',
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
              onPressed: _loadQuiz,
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

  Future<void> _loadQuiz() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
      _attempt = null;
      _summary = null;
      _questions = const [];
      _currentIndex = 0;
      _selectedOptionId = null;
      _answered = false;
      _lastAnswerCorrect = false;
      _favoriteWordIds.clear();
      _favoriteLoadingIds.clear();
    });

    try {
      final quizzes = await _studyApiService.getQuizzesByTopic(widget.setId);
      final activeQuiz = quizzes.where((quiz) => quiz.isActive).isNotEmpty
          ? quizzes.firstWhere((quiz) => quiz.isActive)
          : null;

      if (activeQuiz == null) {
        if (!mounted) {
          return;
        }
        setState(() {
          _loading = false;
          _questions = const [];
        });
        return;
      }

      final attempt = await _studyApiService.startQuiz(activeQuiz.quizId);
      final questions = await _studyApiService.getQuizQuestions(
        attempt.attemptId,
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
        _attempt = attempt;
        _questions = questions
          ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
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

  Future<void> _submitAnswer(String optionId) async {
    final attempt = _attempt;
    if (attempt == null || _submitting) {
      return;
    }

    final question = _questions[_currentIndex];

    setState(() {
      _submitting = true;
      _selectedOptionId = optionId;
    });

    try {
      final result = await _studyApiService.saveQuizAnswer(
        attemptId: attempt.attemptId,
        questionId: question.questionId,
        selectedOptionId: optionId,
      );

      if (!mounted) {
        return;
      }
      setState(() {
        _answered = true;
        _lastAnswerCorrect = result.isCorrect;
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

  Future<void> _goNext() async {
    final attempt = _attempt;
    if (attempt == null) {
      return;
    }

    if (_currentIndex >= _questions.length - 1) {
      setState(() => _submitting = true);
      try {
        final summary = await _studyApiService.submitQuiz(attempt.attemptId);
        if (!mounted) {
          return;
        }
        setState(() {
          _summary = summary;
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
      return;
    }

    setState(() {
      _currentIndex += 1;
      _selectedOptionId = null;
      _answered = false;
      _lastAnswerCorrect = false;
    });
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
