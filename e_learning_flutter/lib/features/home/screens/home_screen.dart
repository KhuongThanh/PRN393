import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/routes.dart';
import '../../../core/models/api_models.dart';
import '../../../core/services/study_api_service.dart';
import '../../../core/services/study_sync_service.dart';
import '../../auth/providers/auth_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color qBlue = Color(0xFF4255FF);
  static const Color qDark = Color(0xFF2E3856);
  static const Color qGray = Color(0xFF939BB4);
  static const Color qYellow = Color(0xFFFFCD1F);

  final StudyApiService _studyApiService = StudyApiService();
  final StudySyncService _studySyncService = StudySyncService.instance;
  late Future<HomeOverviewData> _homeFuture;
  HomeOverviewData? _homeData;

  @override
  void initState() {
    super.initState();
    _homeFuture = _studyApiService.fetchHomeOverview();
    _studySyncService.events.addListener(_handleSyncEvent);
  }

  @override
  void dispose() {
    _studySyncService.events.removeListener(_handleSyncEvent);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: FutureBuilder<HomeOverviewData>(
          future: _homeFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError || !snapshot.hasData) {
              return _buildErrorState(snapshot.error);
            }

            final data = snapshot.data!;
            _homeData = data;
            final topics = data.topics.take(3).toList();
            final latestQuiz = data.dashboard.latestQuiz;
            final completionPercent = data.progressSummary.completionRate
                .round();

            return RefreshIndicator(
              onRefresh: () async {
                final future = _studyApiService.fetchHomeOverview();
                setState(() => _homeFuture = future);
                await future;
              },
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                children: [
                  _buildHeader(data.currentUser),
                  _buildDailyGoalCard(data.dashboard),
                  _buildProgressCard(data.progressSummary, completionPercent),
                  _buildQuickActions(data.dashboard),
                  if (latestQuiz != null) _buildLatestQuizCard(latestQuiz),
                  _buildTopicSection(topics),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(CurrentUserData user) {
    final displayName = user.fullName?.trim().isNotEmpty == true
        ? user.fullName!.trim()
        : user.userName;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [qBlue, qDark],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(18),
                ),
                alignment: Alignment.center,
                child: Text(
                  _initials(displayName),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const Spacer(),
              _headerButton(
                icon: Icons.person_outline,
                onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
              ),
              const SizedBox(width: 8),
              _headerButton(
                icon: Icons.menu_book_outlined,
                onTap: () => Navigator.pushNamed(context, AppRoutes.topics),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Text(
            'Welcome back',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            displayName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Study smarter with your real progress, topics, and practice history synced from the API.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.78),
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyGoalCard(DashboardData dashboard) {
    final target = dashboard.targetDailyWords;
    final done = dashboard.todayStudiedWordCount;
    final percent = target == 0
        ? 0.0
        : (done / target).clamp(0.0, 1.0).toDouble();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
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
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF6D8),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.gps_fixed, color: qYellow),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Daily goal',
                  style: TextStyle(
                    fontSize: 16,
                    color: qDark,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                '$done / $target',
                style: const TextStyle(
                  fontSize: 15,
                  color: qBlue,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 10,
              value: percent,
              backgroundColor: const Color(0xFFECEEF5),
              valueColor: const AlwaysStoppedAnimation<Color>(qBlue),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You have completed ${dashboard.dailyProgressPercent}% of today\'s target.',
            style: const TextStyle(fontSize: 12, color: qGray),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(
    ProgressSummaryData progress,
    int completionPercent,
  ) {
    final totalAttempts =
        progress.totalCorrectCount + progress.totalIncorrectCount;
    final accuracy = totalAttempts == 0
        ? 0
        : ((progress.totalCorrectCount / totalAttempts) * 100).round();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Vocabulary progress',
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
                  title: 'Learned words',
                  value: '${progress.learnedWords}',
                  subtitle: '${progress.totalWords} total',
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
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FE),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                const Icon(Icons.trending_up, color: qBlue),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Overall completion rate is $completionPercent%, with ${progress.notLearnedWords} words still waiting for review.',
                    style: const TextStyle(
                      fontSize: 12,
                      color: qDark,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(DashboardData dashboard) {
    return Row(
      children: [
        Expanded(
          child: _actionCard(
            title: 'Favorites',
            subtitle: '${dashboard.favoriteWordCount} saved words',
            color: const Color(0xFFFF6B6B),
            background: const Color(0xFFFFF2F2),
            icon: Icons.favorite_outline,
            onTap: () => Navigator.pushNamed(context, AppRoutes.favorites),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _actionCard(
            title: 'History',
            subtitle: 'Recent sessions',
            color: qBlue,
            background: const Color(0xFFF0F2FF),
            icon: Icons.history,
            onTap: () => Navigator.pushNamed(context, AppRoutes.history),
          ),
        ),
      ],
    );
  }

  Widget _buildLatestQuizCard(LatestQuizResultData latestQuiz) {
    final score = latestQuiz.score?.toStringAsFixed(1) ?? '--';

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Latest quiz result',
            style: TextStyle(
              fontSize: 16,
              color: qDark,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FE),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF6D8),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.fact_check_outlined, color: qYellow),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        latestQuiz.quizTitle,
                        style: const TextStyle(
                          fontSize: 14,
                          color: qDark,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${latestQuiz.correctAnswers}/${latestQuiz.totalQuestions} correct · score $score',
                        style: const TextStyle(fontSize: 12, color: qGray),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopicSection(List<TopicSummaryData> topics) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Topics',
                  style: TextStyle(
                    fontSize: 16,
                    color: qDark,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.topics),
                child: const Text(
                  'See all',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...topics.map((topic) {
            final route = '/topics/${topic.topicId}';
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () => Navigator.pushNamed(context, route),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F2FF),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.menu_book_outlined,
                          color: qBlue,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              topic.topicName,
                              style: const TextStyle(
                                fontSize: 15,
                                color: qDark,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${topic.wordCount} words · ${topic.learnedWords} learned',
                              style: const TextStyle(
                                fontSize: 12,
                                color: qGray,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(999),
                              child: LinearProgressIndicator(
                                minHeight: 6,
                                value: (topic.completionRate / 100)
                                    .clamp(0.0, 1.0)
                                    .toDouble(),
                                backgroundColor: const Color(0xFFECEEF5),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  qBlue,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        children: [
                          ElevatedButton(
                            onPressed: topic.wordCount == 0
                                ? null
                                : () => Navigator.pushNamed(
                                    context,
                                    '/flashcard/${topic.topicId}',
                                  ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: qBlue,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Study',
                              style: TextStyle(fontWeight: FontWeight.w800),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _headerButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: Colors.white),
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
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(top: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      color: qDark,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 11, color: qGray),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(Object? error) {
    final apiError = error is ApiException ? error : null;
    final isUnauthorized = apiError?.isUnauthorized ?? false;
    final title = isUnauthorized
        ? 'Session expired'
        : 'Unable to load home data';
    final message = isUnauthorized
        ? 'Your login session is no longer valid. Sign in again to reload the latest dashboard data.'
        : _homeErrorMessage(apiError);
    final buttonLabel = isUnauthorized ? 'Log in again' : 'Try again';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 86,
              height: 86,
              decoration: BoxDecoration(
                color: const Color(0xFFF0F2FF),
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Icon(
                Icons.cloud_off_outlined,
                size: 38,
                color: qBlue,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: qDark,
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
              onPressed: () async {
                if (isUnauthorized) {
                  await _returnToLogin();
                  return;
                }

                setState(() {
                  _homeFuture = _studyApiService.fetchHomeOverview();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: qBlue,
                foregroundColor: Colors.white,
                minimumSize: const Size(160, 48),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                buttonLabel,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSyncEvent() {
    final currentData = _homeData;
    if (!mounted || currentData == null) {
      return;
    }

    final event = _studySyncService.events.value;
    HomeOverviewData? updatedData;

    if (event.type == StudySyncEventType.favoriteChanged) {
      final nextCount = _safeCount(
        currentData.dashboard.favoriteWordCount + event.favoriteDelta,
      );
      updatedData = currentData.copyWith(
        dashboard: currentData.dashboard.copyWith(favoriteWordCount: nextCount),
      );
    } else if (event.type == StudySyncEventType.profileUpdated &&
        event.user != null) {
      updatedData = currentData.copyWith(
        currentUser: event.user,
        dashboard: currentData.dashboard.copyWith(
          targetDailyWords: event.user!.targetDailyWords,
        ),
      );
    }

    if (updatedData == null) {
      return;
    }

    setState(() {
      _homeData = updatedData;
      _homeFuture = Future<HomeOverviewData>.value(updatedData);
    });
  }

  int _safeCount(int value) => value < 0 ? 0 : value;

  String _homeErrorMessage(ApiException? error) {
    if (error == null) {
      return 'The app could not fetch your dashboard from the API right now. Pull to refresh or try again.';
    }

    final message = error.message.trim();
    if (message.isEmpty ||
        message.startsWith('Request failed with status code')) {
      return 'The app could not fetch your dashboard from the API right now. Pull to refresh or try again.';
    }

    return message;
  }

  Future<void> _returnToLogin() async {
    await context.read<AuthProvider>().logout();
    if (!mounted) {
      return;
    }

    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
  }

  String _initials(String value) {
    final parts = value.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) {
      return 'U';
    }
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }
}
