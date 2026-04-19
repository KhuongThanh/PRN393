import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/app.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/topics/providers/topic_provider.dart';
import 'features/vocabulary/providers/vocabulary_provider.dart';
import 'features/favorites/providers/favorite_provider.dart';
import 'features/profile/providers/profile_provider.dart';
import 'features/quiz/providers/quiz_provider.dart';
import 'features/flashcard/providers/flashcard_provider.dart';
import 'features/progress/providers/progress_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TopicProvider()),
        ChangeNotifierProvider(create: (_) => VocabularyProvider()),
        ChangeNotifierProvider(create: (_) => FavoriteProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => QuizProvider()),
        ChangeNotifierProvider(create: (_) => FlashcardProvider()),
        ChangeNotifierProvider(create: (_) => ProgressProvider()),
      ],
      child: const MyApp(),
    ),
  );
}
