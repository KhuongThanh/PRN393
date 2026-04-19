import 'package:flutter/material.dart';

import '../../../core/models/api_models.dart';
import '../../../core/services/study_api_service.dart';
import '../../../core/services/study_sync_service.dart';

class TopicDetailScreen extends StatefulWidget {
  const TopicDetailScreen({super.key, required this.setId});

  final String setId;

  @override
  State<TopicDetailScreen> createState() => _TopicDetailScreenState();
}

class _TopicDetailScreenState extends State<TopicDetailScreen> {
  static const Color qBlue = Color(0xFF4255FF);
  static const Color qDark = Color(0xFF2E3856);
  static const Color qGray = Color(0xFF939BB4);

  final StudyApiService _studyApiService = StudyApiService();
  _TopicDetailBundle? _detailData;
  String? _errorMessage;
  bool _isLoading = true;
  final Set<String> _favoriteWordIds = <String>{};
  final Set<String> _favoriteLoadingIds = <String>{};

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail({bool showLoading = true}) async {
    if (showLoading) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final topic = await _studyApiService.getTopic(widget.setId);
      final words = await _studyApiService.getWordsByTopic(widget.setId);
      final progress = await _studyApiService.getTopicProgress(widget.setId);
      final quizzes = await _studyApiService.getQuizzesByTopic(widget.setId);
      Set<String> favoriteWordIds = <String>{};
      try {
        final favorites = await _studyApiService.getFavorites();
        favoriteWordIds = favorites.map((item) => item.wordId).toSet();
      } catch (_) {
        favoriteWordIds = <String>{};
      }

      final bundle = _TopicDetailBundle(
        topic: topic,
        words: words,
        progress: progress,
        quizzes: quizzes,
        favoriteWordIds: favoriteWordIds,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _detailData = bundle;
        _favoriteWordIds
          ..clear()
          ..addAll(bundle.favoriteWordIds);
        _errorMessage = null;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      final message = _errorText(
        error,
        fallback:
            'The app could not fetch topic detail, words, progress, or quiz data from the API.',
      );
      if (_detailData != null) {
        setState(() => _isLoading = false);
        _showMessage(message);
        return;
      }

      setState(() {
        _errorMessage = message;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(child: _buildBody(context)),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading && _detailData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_detailData == null) {
      return _buildErrorState(
        _errorMessage ??
            'The app could not fetch topic detail, words, progress, or quiz data from the API.',
      );
    }

    final data = _detailData!;
    return RefreshIndicator(
      onRefresh: () => _loadDetail(showLoading: false),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildHero(context, data.topic, data.progress),
          _buildProgress(data.progress),
          _buildActions(data),
          _buildWordList(data.words),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildHero(
    BuildContext context,
    TopicSummaryData topic,
    TopicProgressData progress,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [qBlue, qDark],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _heroButton(
                icon: Icons.arrow_back,
                onTap: () => Navigator.pop(context),
              ),
              const Spacer(),
              _heroButton(
                icon: Icons.refresh,
                onTap: () => _loadDetail(showLoading: false),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            width: 66,
            height: 66,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.menu_book_outlined,
              size: 34,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            topic.topicName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            topic.description?.trim().isNotEmpty == true
                ? topic.description!
                : 'This topic was loaded dynamically from the vocabulary API.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.76),
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _infoChip('${progress.totalWords} words'),
              _infoChip('${progress.learnedWords} learned'),
              _infoChip('${(progress.completionRate * 100).round()}% complete'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgress(TopicProgressData progress) {
    final attempts = progress.totalCorrectCount + progress.totalIncorrectCount;
    final accuracy = attempts == 0
        ? 0
        : ((progress.totalCorrectCount / attempts) * 100).round();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Topic progress',
            style: TextStyle(
              fontSize: 16,
              color: qDark,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _metricCard(
                  title: 'Learned',
                  value: '${progress.learnedWords}',
                  subtitle: '${progress.notLearnedWords} left',
                  color: const Color(0xFF1DB954),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _metricCard(
                  title: 'Accuracy',
                  value: '$accuracy%',
                  subtitle: '${progress.totalCorrectCount} correct',
                  color: qBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 10,
              value: progress.completionRate.clamp(0.0, 1.0).toDouble(),
              backgroundColor: const Color(0xFFECEEF5),
              valueColor: const AlwaysStoppedAnimation<Color>(qBlue),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(_TopicDetailBundle data) {
    final firstQuiz = data.quizzes.where((quiz) => quiz.isActive).isNotEmpty
        ? data.quizzes.firstWhere((quiz) => quiz.isActive)
        : null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Study modes',
            style: TextStyle(
              fontSize: 16,
              color: qDark,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _actionCard(
                title: 'Flashcards',
                subtitle: 'Live study session',
                color: qBlue,
                background: const Color(0xFFF0F2FF),
                icon: Icons.style_outlined,
                onTap: data.words.isEmpty
                    ? null
                    : () => Navigator.pushNamed(
                        context,
                        '/flashcard/${data.topic.topicId}',
                      ),
              ),
              _actionCard(
                title: 'Quiz',
                subtitle: firstQuiz == null
                    ? 'No active quiz'
                    : '${firstQuiz.totalQuestions} questions',
                color: const Color(0xFFC8970A),
                background: const Color(0xFFFFF6D8),
                icon: Icons.fact_check_outlined,
                onTap: firstQuiz == null
                    ? null
                    : () => Navigator.pushNamed(
                        context,
                        '/quiz/${data.topic.topicId}',
                      ),
              ),
              _actionCard(
                title: 'Match',
                subtitle: 'Pairs from topic words',
                color: const Color(0xFF1DB954),
                background: const Color(0xFFEFFFF5),
                icon: Icons.grid_view_rounded,
                onTap: data.words.isEmpty
                    ? null
                    : () => Navigator.pushNamed(
                        context,
                        '/match/${data.topic.topicId}',
                      ),
              ),
              _actionCard(
                title: 'Write',
                subtitle: 'Recall by typing',
                color: const Color(0xFFFF6B6B),
                background: const Color(0xFFFFF2F2),
                icon: Icons.edit_note_outlined,
                onTap: data.words.isEmpty
                    ? null
                    : () => Navigator.pushNamed(
                        context,
                        '/write/${data.topic.topicId}',
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWordList(List<WordItemData> words) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Words from API',
            style: TextStyle(
              fontSize: 16,
              color: qDark,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          ...words.map((word) {
            final isFavorite = _favoriteWordIds.contains(word.wordId);
            final isUpdating = _favoriteLoadingIds.contains(word.wordId);

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F2FF),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.translate_outlined, color: qBlue),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          word.wordText,
                          style: const TextStyle(
                            fontSize: 15,
                            color: qDark,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          word.meaning,
                          style: const TextStyle(
                            fontSize: 13,
                            color: qDark,
                            height: 1.5,
                          ),
                        ),
                        if (word.partOfSpeech?.trim().isNotEmpty == true ||
                            word.phonetic?.trim().isNotEmpty == true) ...[
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              if (word.partOfSpeech?.trim().isNotEmpty == true)
                                _wordTag(word.partOfSpeech!),
                              if (word.phonetic?.trim().isNotEmpty == true)
                                _wordTag(word.phonetic!),
                              if (word.difficultyLevel?.trim().isNotEmpty ==
                                  true)
                                _wordTag(word.difficultyLevel!),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  _favoriteButton(
                    isFavorite: isFavorite,
                    isUpdating: isUpdating,
                    onTap: () => _toggleFavorite(word),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _heroButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: Colors.white),
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
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _metricCard({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FE),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: qGray,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              color: color,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(fontSize: 11, color: qGray)),
        ],
      ),
    );
  }

  Widget _actionCard({
    required String title,
    required String subtitle,
    required Color color,
    required Color background,
    required IconData icon,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: onTap == null ? 0.55 : 1,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color),
              const Spacer(),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: color,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 11, color: qDark, height: 1.4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _wordTag(String text) {
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
          color: qBlue,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _favoriteButton({
    required bool isFavorite,
    required bool isUpdating,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: isUpdating ? null : onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: isFavorite ? const Color(0xFFFFF2F2) : const Color(0xFFF8F9FE),
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.center,
        child: isUpdating
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? const Color(0xFFFF6B6B) : qGray,
              ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 42, color: qBlue),
            const SizedBox(height: 12),
            const Text(
              'Unable to load topic detail',
              style: TextStyle(
                fontSize: 22,
                color: qDark,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: qGray, height: 1.5),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: () {
                _loadDetail();
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

  Future<void> _toggleFavorite(WordItemData word) async {
    if (_favoriteLoadingIds.contains(word.wordId)) {
      return;
    }

    final wasFavorite = _favoriteWordIds.contains(word.wordId);
    setState(() {
      _favoriteLoadingIds.add(word.wordId);
      if (wasFavorite) {
        _favoriteWordIds.remove(word.wordId);
      } else {
        _favoriteWordIds.add(word.wordId);
      }
    });

    try {
      if (wasFavorite) {
        await _studyApiService.removeFavorite(word.wordId);
      } else {
        await _studyApiService.addFavorite(word.wordId);
      }

      if (!mounted) {
        return;
      }
      StudySyncService.instance.notifyFavoriteChanged(
        wordId: word.wordId,
        isFavorite: !wasFavorite,
      );
      _showMessage(
        wasFavorite
            ? '"${word.wordText}" was removed from favorites.'
            : '"${word.wordText}" was added to favorites.',
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        if (wasFavorite) {
          _favoriteWordIds.add(word.wordId);
        } else {
          _favoriteWordIds.remove(word.wordId);
        }
      });
      _showMessage(
        _errorText(error, fallback: 'Unable to update favorites right now.'),
      );
    } finally {
      if (mounted) {
        setState(() => _favoriteLoadingIds.remove(word.wordId));
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

class _TopicDetailBundle {
  const _TopicDetailBundle({
    required this.topic,
    required this.words,
    required this.progress,
    required this.quizzes,
    required this.favoriteWordIds,
  });

  final TopicSummaryData topic;
  final List<WordItemData> words;
  final TopicProgressData progress;
  final List<QuizSummaryData> quizzes;
  final Set<String> favoriteWordIds;
}
