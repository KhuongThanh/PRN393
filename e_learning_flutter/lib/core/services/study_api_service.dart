import '../models/api_models.dart';
import '../network/api_client.dart';

class StudyApiService {
  StudyApiService({ApiClient? apiClient})
    : _apiClient = apiClient ?? const ApiClient();

  final ApiClient _apiClient;

  Future<HomeOverviewData> fetchHomeOverview() async {
    final currentUser = await getCurrentUser();
    final dashboardFuture = _getDashboardOrFallback(
      currentUser.targetDailyWords,
    );
    final progressSummaryFuture = _getProgressSummaryOrFallback();
    final topicsFuture = _getTopicsOrFallback();

    return HomeOverviewData(
      currentUser: currentUser,
      dashboard: await dashboardFuture,
      progressSummary: await progressSummaryFuture,
      topics: await topicsFuture,
    );
  }

  Future<List<TopicSummaryData>> getTopics({bool includeStats = false}) async {
    final response = await _apiClient.get('/vocabulary-topics', auth: false);
    final items = _asMapList(response).map(TopicSummaryData.fromJson).toList()
      ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

    if (!includeStats) {
      return items;
    }

    return Future.wait(
      items.map((topic) async {
        try {
          final words = await getWordsByTopic(topic.topicId);
          final progress = await getTopicProgress(topic.topicId);
          return topic.copyWith(
            wordCount: words.length,
            learnedWords: progress.learnedWords,
            completionRate: progress.completionRate,
          );
        } catch (_) {
          return topic.copyWith(
            wordCount: topic.wordCount == 0 ? 0 : topic.wordCount,
          );
        }
      }),
    );
  }

  Future<TopicSummaryData> getTopic(String topicId) async {
    final topics = await getTopics(includeStats: true);
    for (final topic in topics) {
      if (topic.topicId == topicId) {
        return topic;
      }
    }
    throw const ApiException(message: 'Topic not found.', statusCode: 404);
  }

  Future<List<WordItemData>> getWordsByTopic(String topicId) async {
    final response = await _apiClient.get(
      '/vocabulary-topics/$topicId/words',
      auth: false,
    );

    return _asMapList(response).map(WordItemData.fromJson).toList();
  }

  Future<TopicProgressData> getTopicProgress(String topicId) async {
    final response = await _apiClient.get('/progress/topics/$topicId');
    return TopicProgressData.fromJson(_asMap(response));
  }

  Future<List<QuizSummaryData>> getQuizzesByTopic(String topicId) async {
    final response = await _apiClient.get('/topics/$topicId/quizzes');
    return _asMapList(response).map(QuizSummaryData.fromJson).toList();
  }

  Future<CurrentUserData> getCurrentUser() async {
    final response = await _apiClient.get('/Auth/me');
    return CurrentUserData.fromJson(_asMap(response));
  }

  Future<CurrentUserData> updateProfile({
    String? fullName,
    int? targetDailyWords,
    String? avatarUrl,
  }) async {
    final body = <String, dynamic>{};
    if (fullName != null) {
      body['fullName'] = fullName;
    }
    if (targetDailyWords != null) {
      body['targetDailyWords'] = targetDailyWords;
    }
    if (avatarUrl != null) {
      body['avatarUrl'] = avatarUrl;
    }

    final response = await _apiClient.put('/Auth/profile', body: body);
    return CurrentUserData.fromJson(_asMap(response));
  }

  Future<DashboardData> getDashboard() async {
    final response = await _apiClient.get('/dashboard/user');
    return DashboardData.fromJson(_asMap(response));
  }

  Future<ProgressSummaryData> getProgressSummary() async {
    final response = await _apiClient.get('/progress/summary');
    return ProgressSummaryData.fromJson(_asMap(response));
  }

  Future<List<FavoriteWordData>> getFavorites() async {
    final response = await _apiClient.get('/favorites');
    return _asMapList(response).map(FavoriteWordData.fromJson).toList();
  }

  Future<void> addFavorite(String wordId) async {
    await _apiClient.post('/favorites/$wordId');
  }

  Future<void> removeFavorite(String wordId) async {
    await _apiClient.delete('/favorites/$wordId');
  }

  Future<List<StudyHistoryItemData>> getStudyHistory() async {
    final response = await _apiClient.get('/study-sessions/history');
    return _asMapList(response).map(StudyHistoryItemData.fromJson).toList();
  }

  Future<FlashcardSessionStartData> startFlashcardSession({
    required String topicId,
    int? takeCount,
  }) async {
    final body = <String, dynamic>{'sourceType': 'Topic', 'topicId': topicId};
    if (takeCount != null) {
      body['takeCount'] = takeCount;
    }

    final response = await _apiClient.post('/study-sessions/start', body: body);
    return FlashcardSessionStartData.fromJson(_asMap(response));
  }

  Future<FlashcardReviewData> reviewFlashcard({
    required String sessionId,
    required String wordId,
    required bool isRemembered,
    required int reviewOrder,
  }) async {
    final response = await _apiClient.post(
      '/study-sessions/$sessionId/review',
      body: {
        'wordId': wordId,
        'isRemembered': isRemembered,
        'reviewOrder': reviewOrder,
      },
    );
    return FlashcardReviewData.fromJson(_asMap(response));
  }

  Future<FlashcardFinishData> finishFlashcardSession(String sessionId) async {
    final response = await _apiClient.post('/study-sessions/$sessionId/finish');
    return FlashcardFinishData.fromJson(_asMap(response));
  }

  Future<QuizAttemptStartData> startQuiz(String quizId) async {
    final response = await _apiClient.post('/quizzes/$quizId/start');
    return QuizAttemptStartData.fromJson(_asMap(response));
  }

  Future<List<QuizQuestionData>> getQuizQuestions(String attemptId) async {
    final response = await _apiClient.get(
      '/quiz-attempts/$attemptId/questions',
    );
    return _asMapList(response).map(QuizQuestionData.fromJson).toList();
  }

  Future<QuizAnswerResultData> saveQuizAnswer({
    required String attemptId,
    required String questionId,
    required String selectedOptionId,
  }) async {
    final response = await _apiClient.post(
      '/quiz-attempts/$attemptId/answers',
      body: {'questionId': questionId, 'selectedOptionId': selectedOptionId},
    );
    return QuizAnswerResultData.fromJson(_asMap(response));
  }

  Future<QuizSubmitResultData> submitQuiz(String attemptId) async {
    final response = await _apiClient.post('/quiz-attempts/$attemptId/submit');
    return QuizSubmitResultData.fromJson(_asMap(response));
  }

  Future<DashboardData> _getDashboardOrFallback(int targetDailyWords) async {
    try {
      return await getDashboard();
    } on ApiException catch (error) {
      if (error.isUnauthorized) {
        rethrow;
      }
      return DashboardData.empty(targetDailyWords: targetDailyWords);
    } catch (_) {
      return DashboardData.empty(targetDailyWords: targetDailyWords);
    }
  }

  Future<ProgressSummaryData> _getProgressSummaryOrFallback() async {
    try {
      return await getProgressSummary();
    } on ApiException catch (error) {
      if (error.isUnauthorized) {
        rethrow;
      }
      return const ProgressSummaryData.empty();
    } catch (_) {
      return const ProgressSummaryData.empty();
    }
  }

  Future<List<TopicSummaryData>> _getTopicsOrFallback() async {
    try {
      return await getTopics(includeStats: true);
    } catch (_) {
      return const [];
    }
  }
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  return <String, dynamic>{};
}

List<Map<String, dynamic>> _asMapList(dynamic value) {
  if (value is List) {
    return value.whereType<Map<String, dynamic>>().toList();
  }
  return const [];
}
