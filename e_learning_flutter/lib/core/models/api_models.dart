class ApiException implements Exception {
  const ApiException({required this.message, required this.statusCode});

  final String message;
  final int statusCode;

  bool get isUnauthorized => statusCode == 401 || statusCode == 403;

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class TopicSummaryData {
  const TopicSummaryData({
    required this.topicId,
    required this.topicName,
    required this.description,
    required this.imageUrl,
    required this.displayOrder,
    required this.wordCount,
    required this.learnedWords,
    required this.completionRate,
  });

  final String topicId;
  final String topicName;
  final String? description;
  final String? imageUrl;
  final int displayOrder;
  final int wordCount;
  final int learnedWords;
  final double completionRate;

  TopicSummaryData copyWith({
    int? wordCount,
    int? learnedWords,
    double? completionRate,
  }) {
    return TopicSummaryData(
      topicId: topicId,
      topicName: topicName,
      description: description,
      imageUrl: imageUrl,
      displayOrder: displayOrder,
      wordCount: wordCount ?? this.wordCount,
      learnedWords: learnedWords ?? this.learnedWords,
      completionRate: completionRate ?? this.completionRate,
    );
  }

  factory TopicSummaryData.fromJson(Map<String, dynamic> json) {
    return TopicSummaryData(
      topicId: json['topicId']?.toString() ?? '',
      topicName: json['topicName']?.toString() ?? '',
      description: json['description']?.toString(),
      imageUrl: json['imageUrl']?.toString(),
      displayOrder: _asInt(json['displayOrder']),
      wordCount: _asInt(json['wordCount']),
      learnedWords: _asInt(json['learnedWords']),
      completionRate: _asDouble(json['completionRate']),
    );
  }
}

class WordItemData {
  const WordItemData({
    required this.wordId,
    required this.topicId,
    required this.wordText,
    required this.meaning,
    required this.partOfSpeech,
    required this.phonetic,
    required this.difficultyLevel,
    required this.exampleSentence,
    required this.imageUrl,
  });

  final String wordId;
  final String topicId;
  final String wordText;
  final String meaning;
  final String? partOfSpeech;
  final String? phonetic;
  final String? difficultyLevel;
  final String? exampleSentence;
  final String? imageUrl;

  factory WordItemData.fromJson(Map<String, dynamic> json) {
    return WordItemData(
      wordId: json['wordId']?.toString() ?? '',
      topicId: json['topicId']?.toString() ?? '',
      wordText: json['wordText']?.toString() ?? '',
      meaning: json['meaning']?.toString() ?? '',
      partOfSpeech: json['partOfSpeech']?.toString(),
      phonetic: json['phonetic']?.toString(),
      difficultyLevel: json['difficultyLevel']?.toString(),
      exampleSentence: json['exampleSentence']?.toString(),
      imageUrl: json['imageUrl']?.toString(),
    );
  }
}

class TopicProgressData {
  const TopicProgressData({
    required this.topicId,
    required this.topicName,
    required this.totalWords,
    required this.learnedWords,
    required this.notLearnedWords,
    required this.totalCorrectCount,
    required this.totalIncorrectCount,
    required this.lastStudiedAt,
    required this.completionRate,
  });

  final String topicId;
  final String topicName;
  final int totalWords;
  final int learnedWords;
  final int notLearnedWords;
  final int totalCorrectCount;
  final int totalIncorrectCount;
  final DateTime? lastStudiedAt;
  final double completionRate;

  factory TopicProgressData.fromJson(Map<String, dynamic> json) {
    return TopicProgressData(
      topicId: json['topicId']?.toString() ?? '',
      topicName: json['topicName']?.toString() ?? '',
      totalWords: _asInt(json['totalWords']),
      learnedWords: _asInt(json['learnedWords']),
      notLearnedWords: _asInt(json['notLearnedWords']),
      totalCorrectCount: _asInt(json['totalCorrectCount']),
      totalIncorrectCount: _asInt(json['totalIncorrectCount']),
      lastStudiedAt: _asDateTime(json['lastStudiedAt']),
      completionRate: _asDouble(json['completionRate']),
    );
  }
}

class QuizSummaryData {
  const QuizSummaryData({
    required this.quizId,
    required this.topicId,
    required this.quizTitle,
    required this.description,
    required this.timeLimitMinutes,
    required this.isActive,
    required this.totalQuestions,
  });

  final String quizId;
  final String topicId;
  final String quizTitle;
  final String? description;
  final int? timeLimitMinutes;
  final bool isActive;
  final int totalQuestions;

  factory QuizSummaryData.fromJson(Map<String, dynamic> json) {
    return QuizSummaryData(
      quizId: json['quizId']?.toString() ?? '',
      topicId: json['topicId']?.toString() ?? '',
      quizTitle: json['quizTitle']?.toString() ?? '',
      description: json['description']?.toString(),
      timeLimitMinutes: _asNullableInt(json['timeLimitMinutes']),
      isActive: _asBool(json['isActive']),
      totalQuestions: _asInt(json['totalQuestions']),
    );
  }
}

class CurrentUserData {
  const CurrentUserData({
    required this.userId,
    required this.userName,
    required this.email,
    required this.roles,
    required this.fullName,
    required this.avatarUrl,
    required this.targetDailyWords,
    required this.isActive,
  });

  final String userId;
  final String userName;
  final String email;
  final List<String> roles;
  final String? fullName;
  final String? avatarUrl;
  final int targetDailyWords;
  final bool isActive;

  CurrentUserData copyWith({
    String? userName,
    String? email,
    List<String>? roles,
    String? fullName,
    String? avatarUrl,
    int? targetDailyWords,
    bool? isActive,
  }) {
    return CurrentUserData(
      userId: userId,
      userName: userName ?? this.userName,
      email: email ?? this.email,
      roles: roles ?? this.roles,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      targetDailyWords: targetDailyWords ?? this.targetDailyWords,
      isActive: isActive ?? this.isActive,
    );
  }

  factory CurrentUserData.fromJson(Map<String, dynamic> json) {
    return CurrentUserData(
      userId: json['userId']?.toString() ?? '',
      userName: json['userName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      roles: _asStringList(json['roles']),
      fullName: json['fullName']?.toString(),
      avatarUrl: json['avatarUrl']?.toString(),
      targetDailyWords: _asInt(json['targetDailyWords']),
      isActive: _asBool(json['isActive']),
    );
  }
}

class LatestQuizResultData {
  const LatestQuizResultData({
    required this.attemptId,
    required this.quizId,
    required this.quizTitle,
    required this.submittedAt,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.score,
  });

  final String attemptId;
  final String quizId;
  final String quizTitle;
  final DateTime? submittedAt;
  final int totalQuestions;
  final int correctAnswers;
  final double? score;

  factory LatestQuizResultData.fromJson(Map<String, dynamic> json) {
    return LatestQuizResultData(
      attemptId: json['attemptId']?.toString() ?? '',
      quizId: json['quizId']?.toString() ?? '',
      quizTitle: json['quizTitle']?.toString() ?? '',
      submittedAt: _asDateTime(json['submittedAt']),
      totalQuestions: _asInt(json['totalQuestions']),
      correctAnswers: _asInt(json['correctAnswers']),
      score: _asNullableDouble(json['score']),
    );
  }
}

class DashboardData {
  const DashboardData({
    required this.learnedTopicCount,
    required this.learnedWordCount,
    required this.favoriteWordCount,
    required this.targetDailyWords,
    required this.todayStudiedWordCount,
    required this.dailyProgressPercent,
    required this.latestQuiz,
  });

  const DashboardData.empty({this.targetDailyWords = 10})
    : learnedTopicCount = 0,
      learnedWordCount = 0,
      favoriteWordCount = 0,
      todayStudiedWordCount = 0,
      dailyProgressPercent = 0,
      latestQuiz = null;

  final int learnedTopicCount;
  final int learnedWordCount;
  final int favoriteWordCount;
  final int targetDailyWords;
  final int todayStudiedWordCount;
  final int dailyProgressPercent;
  final LatestQuizResultData? latestQuiz;

  DashboardData copyWith({
    int? learnedTopicCount,
    int? learnedWordCount,
    int? favoriteWordCount,
    int? targetDailyWords,
    int? todayStudiedWordCount,
    int? dailyProgressPercent,
    LatestQuizResultData? latestQuiz,
  }) {
    return DashboardData(
      learnedTopicCount: learnedTopicCount ?? this.learnedTopicCount,
      learnedWordCount: learnedWordCount ?? this.learnedWordCount,
      favoriteWordCount: favoriteWordCount ?? this.favoriteWordCount,
      targetDailyWords: targetDailyWords ?? this.targetDailyWords,
      todayStudiedWordCount:
          todayStudiedWordCount ?? this.todayStudiedWordCount,
      dailyProgressPercent: dailyProgressPercent ?? this.dailyProgressPercent,
      latestQuiz: latestQuiz ?? this.latestQuiz,
    );
  }

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      learnedTopicCount: _asInt(json['learnedTopicCount']),
      learnedWordCount: _asInt(json['learnedWordCount']),
      favoriteWordCount: _asInt(json['favoriteWordCount']),
      targetDailyWords: _asInt(json['targetDailyWords']),
      todayStudiedWordCount: _asInt(json['todayStudiedWordCount']),
      dailyProgressPercent: _asInt(json['dailyProgressPercent']),
      latestQuiz: json['latestQuiz'] is Map<String, dynamic>
          ? LatestQuizResultData.fromJson(
              json['latestQuiz'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}

class ProgressSummaryData {
  const ProgressSummaryData({
    required this.totalWords,
    required this.learnedWords,
    required this.notLearnedWords,
    required this.totalCorrectCount,
    required this.totalIncorrectCount,
    required this.lastStudiedAt,
    required this.completionRate,
  });

  const ProgressSummaryData.empty()
    : totalWords = 0,
      learnedWords = 0,
      notLearnedWords = 0,
      totalCorrectCount = 0,
      totalIncorrectCount = 0,
      lastStudiedAt = null,
      completionRate = 0;

  final int totalWords;
  final int learnedWords;
  final int notLearnedWords;
  final int totalCorrectCount;
  final int totalIncorrectCount;
  final DateTime? lastStudiedAt;
  final double completionRate;

  factory ProgressSummaryData.fromJson(Map<String, dynamic> json) {
    return ProgressSummaryData(
      totalWords: _asInt(json['totalWords']),
      learnedWords: _asInt(json['learnedWords']),
      notLearnedWords: _asInt(json['notLearnedWords']),
      totalCorrectCount: _asInt(json['totalCorrectCount']),
      totalIncorrectCount: _asInt(json['totalIncorrectCount']),
      lastStudiedAt: _asDateTime(json['lastStudiedAt']),
      completionRate: _asDouble(json['completionRate']),
    );
  }
}

class FavoriteWordData {
  const FavoriteWordData({
    required this.wordId,
    required this.wordText,
    required this.meaning,
    required this.partOfSpeech,
    required this.phonetic,
    required this.imageUrl,
    required this.topicId,
    required this.topicName,
    required this.isFavorite,
  });

  final String wordId;
  final String wordText;
  final String meaning;
  final String? partOfSpeech;
  final String? phonetic;
  final String? imageUrl;
  final String? topicId;
  final String? topicName;
  final bool isFavorite;

  factory FavoriteWordData.fromJson(Map<String, dynamic> json) {
    return FavoriteWordData(
      wordId: json['wordId']?.toString() ?? '',
      wordText: json['wordText']?.toString() ?? '',
      meaning: json['meaning']?.toString() ?? '',
      partOfSpeech: json['partOfSpeech']?.toString(),
      phonetic: json['phonetic']?.toString(),
      imageUrl: json['imageUrl']?.toString(),
      topicId: json['topicId']?.toString(),
      topicName: json['topicName']?.toString(),
      isFavorite: _asBool(json['isFavorite']),
    );
  }
}

class StudyHistoryItemData {
  const StudyHistoryItemData({
    required this.sessionId,
    required this.sourceType,
    required this.sourceName,
    required this.topicId,
    required this.topicName,
    required this.sessionType,
    required this.startedAt,
    required this.endedAt,
    required this.totalWords,
    required this.rememberedCount,
    required this.notRememberedCount,
    required this.reviewedCount,
    required this.isFinished,
    required this.completionRate,
    required this.durationSeconds,
  });

  final String sessionId;
  final String sourceType;
  final String? sourceName;
  final String? topicId;
  final String? topicName;
  final String sessionType;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int totalWords;
  final int rememberedCount;
  final int notRememberedCount;
  final int reviewedCount;
  final bool isFinished;
  final double completionRate;
  final int? durationSeconds;

  factory StudyHistoryItemData.fromJson(Map<String, dynamic> json) {
    return StudyHistoryItemData(
      sessionId: json['sessionId']?.toString() ?? '',
      sourceType: json['sourceType']?.toString() ?? '',
      sourceName: json['sourceName']?.toString(),
      topicId: json['topicId']?.toString(),
      topicName: json['topicName']?.toString(),
      sessionType: json['sessionType']?.toString() ?? 'Flashcard',
      startedAt: _asDateTime(json['startedAt']) ?? DateTime.now(),
      endedAt: _asDateTime(json['endedAt']),
      totalWords: _asInt(json['totalWords']),
      rememberedCount: _asInt(json['rememberedCount']),
      notRememberedCount: _asInt(json['notRememberedCount']),
      reviewedCount: _asInt(json['reviewedCount']),
      isFinished: _asBool(json['isFinished']),
      completionRate: _asDouble(json['completionRate']),
      durationSeconds: _asNullableInt(json['durationSeconds']),
    );
  }
}

class FlashcardWordData {
  const FlashcardWordData({
    required this.wordId,
    required this.wordText,
    required this.meaning,
    required this.exampleSentence,
    required this.partOfSpeech,
    required this.phonetic,
    required this.audioUrl,
    required this.imageUrl,
    required this.difficultyLevel,
  });

  final String wordId;
  final String wordText;
  final String meaning;
  final String? exampleSentence;
  final String? partOfSpeech;
  final String? phonetic;
  final String? audioUrl;
  final String? imageUrl;
  final String? difficultyLevel;

  factory FlashcardWordData.fromJson(Map<String, dynamic> json) {
    return FlashcardWordData(
      wordId: json['wordId']?.toString() ?? '',
      wordText: json['wordText']?.toString() ?? '',
      meaning: json['meaning']?.toString() ?? '',
      exampleSentence: json['exampleSentence']?.toString(),
      partOfSpeech: json['partOfSpeech']?.toString(),
      phonetic: json['phonetic']?.toString(),
      audioUrl: json['audioUrl']?.toString(),
      imageUrl: json['imageUrl']?.toString(),
      difficultyLevel: json['difficultyLevel']?.toString(),
    );
  }
}

class FlashcardSessionStartData {
  const FlashcardSessionStartData({
    required this.sessionId,
    required this.sourceType,
    required this.sourceName,
    required this.topicId,
    required this.topicName,
    required this.sessionType,
    required this.startedAt,
    required this.totalWords,
    required this.words,
  });

  final String sessionId;
  final String sourceType;
  final String? sourceName;
  final String? topicId;
  final String? topicName;
  final String sessionType;
  final DateTime startedAt;
  final int totalWords;
  final List<FlashcardWordData> words;

  factory FlashcardSessionStartData.fromJson(Map<String, dynamic> json) {
    return FlashcardSessionStartData(
      sessionId: json['sessionId']?.toString() ?? '',
      sourceType: json['sourceType']?.toString() ?? '',
      sourceName: json['sourceName']?.toString(),
      topicId: json['topicId']?.toString(),
      topicName: json['topicName']?.toString(),
      sessionType: json['sessionType']?.toString() ?? 'Flashcard',
      startedAt: _asDateTime(json['startedAt']) ?? DateTime.now(),
      totalWords: _asInt(json['totalWords']),
      words: _asMapList(json['words']).map(FlashcardWordData.fromJson).toList(),
    );
  }
}

class FlashcardReviewData {
  const FlashcardReviewData({
    required this.sessionId,
    required this.wordId,
    required this.isRemembered,
    required this.reviewOrder,
    required this.reviewedAt,
    required this.reviewedCount,
    required this.remainingCount,
    required this.rememberedCount,
    required this.notRememberedCount,
    required this.totalWords,
    required this.isCompleted,
  });

  final String sessionId;
  final String wordId;
  final bool isRemembered;
  final int reviewOrder;
  final DateTime? reviewedAt;
  final int reviewedCount;
  final int remainingCount;
  final int rememberedCount;
  final int notRememberedCount;
  final int totalWords;
  final bool isCompleted;

  factory FlashcardReviewData.fromJson(Map<String, dynamic> json) {
    return FlashcardReviewData(
      sessionId: json['sessionId']?.toString() ?? '',
      wordId: json['wordId']?.toString() ?? '',
      isRemembered: _asBool(json['isRemembered']),
      reviewOrder: _asInt(json['reviewOrder']),
      reviewedAt: _asDateTime(json['reviewedAt']),
      reviewedCount: _asInt(json['reviewedCount']),
      remainingCount: _asInt(json['remainingCount']),
      rememberedCount: _asInt(json['rememberedCount']),
      notRememberedCount: _asInt(json['notRememberedCount']),
      totalWords: _asInt(json['totalWords']),
      isCompleted: _asBool(json['isCompleted']),
    );
  }
}

class FlashcardFinishData {
  const FlashcardFinishData({
    required this.sessionId,
    required this.topicName,
    required this.totalWords,
    required this.reviewedCount,
    required this.rememberedCount,
    required this.notRememberedCount,
    required this.completionRate,
    required this.durationSeconds,
  });

  final String sessionId;
  final String? topicName;
  final int totalWords;
  final int reviewedCount;
  final int rememberedCount;
  final int notRememberedCount;
  final double completionRate;
  final int durationSeconds;

  factory FlashcardFinishData.fromJson(Map<String, dynamic> json) {
    return FlashcardFinishData(
      sessionId: json['sessionId']?.toString() ?? '',
      topicName: json['topicName']?.toString(),
      totalWords: _asInt(json['totalWords']),
      reviewedCount: _asInt(json['reviewedCount']),
      rememberedCount: _asInt(json['rememberedCount']),
      notRememberedCount: _asInt(json['notRememberedCount']),
      completionRate: _asDouble(json['completionRate']),
      durationSeconds: _asInt(json['durationSeconds']),
    );
  }
}

class QuizAttemptStartData {
  const QuizAttemptStartData({
    required this.attemptId,
    required this.quizId,
    required this.quizTitle,
    required this.startedAt,
    required this.totalQuestions,
    required this.timeLimitMinutes,
  });

  final String attemptId;
  final String quizId;
  final String quizTitle;
  final DateTime? startedAt;
  final int totalQuestions;
  final int? timeLimitMinutes;

  factory QuizAttemptStartData.fromJson(Map<String, dynamic> json) {
    return QuizAttemptStartData(
      attemptId: json['attemptId']?.toString() ?? '',
      quizId: json['quizId']?.toString() ?? '',
      quizTitle: json['quizTitle']?.toString() ?? '',
      startedAt: _asDateTime(json['startedAt']),
      totalQuestions: _asInt(json['totalQuestions']),
      timeLimitMinutes: _asNullableInt(json['timeLimitMinutes']),
    );
  }
}

class QuizQuestionOptionData {
  const QuizQuestionOptionData({
    required this.optionId,
    required this.optionText,
    required this.displayOrder,
  });

  final String optionId;
  final String optionText;
  final int displayOrder;

  factory QuizQuestionOptionData.fromJson(Map<String, dynamic> json) {
    return QuizQuestionOptionData(
      optionId: json['optionId']?.toString() ?? '',
      optionText: json['optionText']?.toString() ?? '',
      displayOrder: _asInt(json['displayOrder']),
    );
  }
}

class QuizQuestionData {
  const QuizQuestionData({
    required this.questionId,
    required this.questionText,
    required this.displayOrder,
    required this.wordId,
    required this.selectedOptionId,
    required this.options,
  });

  final String questionId;
  final String questionText;
  final int displayOrder;
  final String? wordId;
  final String? selectedOptionId;
  final List<QuizQuestionOptionData> options;

  factory QuizQuestionData.fromJson(Map<String, dynamic> json) {
    return QuizQuestionData(
      questionId: json['questionId']?.toString() ?? '',
      questionText: json['questionText']?.toString() ?? '',
      displayOrder: _asInt(json['displayOrder']),
      wordId: json['wordId']?.toString(),
      selectedOptionId: json['selectedOptionId']?.toString(),
      options: _asMapList(
        json['options'],
      ).map(QuizQuestionOptionData.fromJson).toList(),
    );
  }
}

class QuizAnswerResultData {
  const QuizAnswerResultData({
    required this.attemptId,
    required this.questionId,
    required this.selectedOptionId,
    required this.isCorrect,
    required this.answeredAt,
  });

  final String attemptId;
  final String questionId;
  final String selectedOptionId;
  final bool isCorrect;
  final DateTime? answeredAt;

  factory QuizAnswerResultData.fromJson(Map<String, dynamic> json) {
    return QuizAnswerResultData(
      attemptId: json['attemptId']?.toString() ?? '',
      questionId: json['questionId']?.toString() ?? '',
      selectedOptionId: json['selectedOptionId']?.toString() ?? '',
      isCorrect: _asBool(json['isCorrect']),
      answeredAt: _asDateTime(json['answeredAt']),
    );
  }
}

class QuizSubmitResultData {
  const QuizSubmitResultData({
    required this.attemptId,
    required this.quizId,
    required this.startedAt,
    required this.submittedAt,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.score,
  });

  final String attemptId;
  final String quizId;
  final DateTime? startedAt;
  final DateTime? submittedAt;
  final int totalQuestions;
  final int correctAnswers;
  final double score;

  factory QuizSubmitResultData.fromJson(Map<String, dynamic> json) {
    return QuizSubmitResultData(
      attemptId: json['attemptId']?.toString() ?? '',
      quizId: json['quizId']?.toString() ?? '',
      startedAt: _asDateTime(json['startedAt']),
      submittedAt: _asDateTime(json['submittedAt']),
      totalQuestions: _asInt(json['totalQuestions']),
      correctAnswers: _asInt(json['correctAnswers']),
      score: _asDouble(json['score']),
    );
  }
}

class HomeOverviewData {
  const HomeOverviewData({
    required this.currentUser,
    required this.dashboard,
    required this.progressSummary,
    required this.topics,
  });

  final CurrentUserData currentUser;
  final DashboardData dashboard;
  final ProgressSummaryData progressSummary;
  final List<TopicSummaryData> topics;

  HomeOverviewData copyWith({
    CurrentUserData? currentUser,
    DashboardData? dashboard,
    ProgressSummaryData? progressSummary,
    List<TopicSummaryData>? topics,
  }) {
    return HomeOverviewData(
      currentUser: currentUser ?? this.currentUser,
      dashboard: dashboard ?? this.dashboard,
      progressSummary: progressSummary ?? this.progressSummary,
      topics: topics ?? this.topics,
    );
  }
}

int _asInt(dynamic value) {
  if (value is int) {
    return value;
  }
  if (value is double) {
    return value.round();
  }
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

int? _asNullableInt(dynamic value) {
  if (value == null) {
    return null;
  }
  return _asInt(value);
}

double _asDouble(dynamic value) {
  if (value is double) {
    return value;
  }
  if (value is int) {
    return value.toDouble();
  }
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

double? _asNullableDouble(dynamic value) {
  if (value == null) {
    return null;
  }
  return _asDouble(value);
}

bool _asBool(dynamic value) {
  if (value is bool) {
    return value;
  }
  final raw = value?.toString().toLowerCase();
  return raw == 'true' || raw == '1';
}

DateTime? _asDateTime(dynamic value) {
  if (value == null) {
    return null;
  }
  return DateTime.tryParse(value.toString());
}

List<Map<String, dynamic>> _asMapList(dynamic value) {
  if (value is List) {
    return value.whereType<Map<String, dynamic>>().toList();
  }
  return const [];
}

List<String> _asStringList(dynamic value) {
  if (value is List) {
    return value.map((item) => item.toString()).toList();
  }
  return const [];
}
