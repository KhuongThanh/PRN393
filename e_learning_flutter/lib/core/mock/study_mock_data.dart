import 'dart:math';

import 'package:flutter/material.dart';

class StudyCardData {
  final String term;
  final String definition;
  final String example;

  const StudyCardData({
    required this.term,
    required this.definition,
    required this.example,
  });
}

class StudySetData {
  final String id;
  final String title;
  final String description;
  final String author;
  final String emoji;
  final Color accentColor;
  final bool isFavorite;
  final int learnedCount;
  final List<String> tags;
  final List<StudyCardData> cards;

  const StudySetData({
    required this.id,
    required this.title,
    required this.description,
    required this.author,
    required this.emoji,
    required this.accentColor,
    required this.isFavorite,
    required this.learnedCount,
    required this.tags,
    required this.cards,
  });

  int get termCount => cards.length;
  double get learnedPercent =>
      termCount == 0 ? 0 : learnedCount.clamp(0, termCount) / termCount;
}

class ActivityData {
  final String title;
  final String subtitle;
  final String when;
  final String route;
  final IconData icon;
  final Color color;

  const ActivityData({
    required this.title,
    required this.subtitle,
    required this.when,
    required this.route,
    required this.icon,
    required this.color,
  });
}

class StudyMockData {
  static const Color quizletBlue = Color(0xFF4255FF);
  static const Color quizletDark = Color(0xFF2E3856);

  static final List<StudySetData> sets = [
    StudySetData(
      id: '1',
      title: 'Tu vung Kinh doanh',
      description: 'Bo the cho email, meeting va proposal trong cong viec.',
      author: 'Van A',
      emoji: '💼',
      accentColor: const Color(0xFF4255FF),
      isFavorite: true,
      learnedCount: 4,
      tags: const ['business', 'presentation', 'office'],
      cards: const [
        StudyCardData(
          term: 'deadline',
          definition: 'the final time a task must be finished',
          example: 'We need the slides before Friday deadline.',
        ),
        StudyCardData(
          term: 'proposal',
          definition: 'a document that suggests a plan or offer',
          example: 'The client asked for a short proposal first.',
        ),
        StudyCardData(
          term: 'revenue',
          definition: 'income made by a company before expenses',
          example: 'Monthly revenue is growing steadily.',
        ),
        StudyCardData(
          term: 'stakeholder',
          definition: 'a person or group affected by a project',
          example: 'All stakeholders joined the kickoff call.',
        ),
        StudyCardData(
          term: 'invoice',
          definition: 'a bill that asks for payment',
          example: 'Finance sent the invoice this afternoon.',
        ),
        StudyCardData(
          term: 'negotiation',
          definition: 'a discussion to reach an agreement',
          example: 'Price negotiation took two weeks.',
        ),
      ],
    ),
    StudySetData(
      id: '2',
      title: 'Cong nghe va IT',
      description: 'Nhung thuat ngu can gap trong dev, product va cloud.',
      author: 'Van A',
      emoji: '💻',
      accentColor: const Color(0xFFFF6B6B),
      isFavorite: false,
      learnedCount: 2,
      tags: const ['software', 'backend', 'cloud'],
      cards: const [
        StudyCardData(
          term: 'deployment',
          definition: 'the process of releasing software to users',
          example: 'The deployment starts after tests pass.',
        ),
        StudyCardData(
          term: 'latency',
          definition: 'the delay before data is transferred',
          example: 'High latency slows down the app.',
        ),
        StudyCardData(
          term: 'database',
          definition: 'an organized collection of stored data',
          example: 'User data lives in the database.',
        ),
        StudyCardData(
          term: 'endpoint',
          definition: 'a URL where an API can be accessed',
          example: 'The mobile app calls the login endpoint.',
        ),
        StudyCardData(
          term: 'cache',
          definition: 'temporary storage used to speed up access',
          example: 'A cache reduces repeated requests.',
        ),
        StudyCardData(
          term: 'rollback',
          definition: 'a return to an earlier software version',
          example: 'We performed a rollback after the bug.',
        ),
      ],
    ),
    StudySetData(
      id: '3',
      title: 'Du lich Anh ngu',
      description: 'Mau cau va tu vung cho san bay, khach san va di chuyen.',
      author: 'Van A',
      emoji: '✈️',
      accentColor: const Color(0xFF26C6DA),
      isFavorite: true,
      learnedCount: 5,
      tags: const ['travel', 'airport', 'hotel'],
      cards: const [
        StudyCardData(
          term: 'boarding pass',
          definition: 'a document that lets you enter the plane',
          example: 'Please show your boarding pass at gate 12.',
        ),
        StudyCardData(
          term: 'reservation',
          definition: 'an arrangement to keep a room or seat for you',
          example: 'I have a reservation under Minh Tran.',
        ),
        StudyCardData(
          term: 'luggage',
          definition: 'bags and suitcases taken on a trip',
          example: 'My luggage is still at the carousel.',
        ),
        StudyCardData(
          term: 'itinerary',
          definition: 'a plan for a trip with places and times',
          example: 'Our itinerary includes Da Nang and Hue.',
        ),
        StudyCardData(
          term: 'departure',
          definition: 'the act of leaving a place',
          example: 'Departure is scheduled for 6:30 AM.',
        ),
        StudyCardData(
          term: 'check-in',
          definition: 'the process of arriving and registering',
          example: 'Hotel check-in begins at 2 PM.',
        ),
      ],
    ),
    StudySetData(
      id: '4',
      title: 'Am thuc va Do uong',
      description: 'Tu de goi mon, mo ta huong vi va thanh phan.',
      author: 'Van A',
      emoji: '🍜',
      accentColor: const Color(0xFF43A047),
      isFavorite: false,
      learnedCount: 1,
      tags: const ['food', 'restaurant'],
      cards: const [
        StudyCardData(
          term: 'spicy',
          definition: 'having a strong hot flavor',
          example: 'This sauce is too spicy for me.',
        ),
        StudyCardData(
          term: 'ingredient',
          definition: 'one of the foods used to make a dish',
          example: 'Fresh herbs are the key ingredient.',
        ),
        StudyCardData(
          term: 'appetizer',
          definition: 'a small dish served before the main course',
          example: 'We ordered spring rolls as an appetizer.',
        ),
        StudyCardData(
          term: 'beverage',
          definition: 'a drink of any kind',
          example: 'Tea is my favorite beverage.',
        ),
        StudyCardData(
          term: 'crispy',
          definition: 'pleasantly hard and easy to break',
          example: 'The chicken skin is extra crispy.',
        ),
        StudyCardData(
          term: 'portion',
          definition: 'the amount of food served to one person',
          example: 'The portion is large enough to share.',
        ),
      ],
    ),
    StudySetData(
      id: '5',
      title: 'The thao quoc te',
      description: 'Cac cum tu trong binh luan tran dau va tap luyen.',
      author: 'Van A',
      emoji: '⚽',
      accentColor: const Color(0xFFFB8C00),
      isFavorite: false,
      learnedCount: 0,
      tags: const ['sports', 'fitness'],
      cards: const [
        StudyCardData(
          term: 'kickoff',
          definition: 'the official start of a football match',
          example: 'Kickoff is at 8 PM tonight.',
        ),
        StudyCardData(
          term: 'defender',
          definition: 'a player who protects the goal area',
          example: 'The defender blocked the shot.',
        ),
        StudyCardData(
          term: 'tournament',
          definition: 'a competition with many matches or rounds',
          example: 'Our team joined the local tournament.',
        ),
        StudyCardData(
          term: 'stamina',
          definition: 'physical energy that lasts a long time',
          example: 'Running helps build stamina.',
        ),
        StudyCardData(
          term: 'penalty',
          definition: 'a punishment or special shot after a foul',
          example: 'The referee awarded a penalty.',
        ),
        StudyCardData(
          term: 'warm-up',
          definition: 'light exercise done before intense activity',
          example: 'Do a short warm-up before training.',
        ),
      ],
    ),
    StudySetData(
      id: '6',
      title: 'Y te va Suc khoe',
      description: 'Tu co ban trong kham benh, trieu chung va dieu tri.',
      author: 'Van A',
      emoji: '🏥',
      accentColor: const Color(0xFFE91E63),
      isFavorite: true,
      learnedCount: 3,
      tags: const ['health', 'clinic'],
      cards: const [
        StudyCardData(
          term: 'symptom',
          definition: 'a sign that shows illness or a condition',
          example: 'A fever is a common symptom.',
        ),
        StudyCardData(
          term: 'prescription',
          definition: 'a written order for medicine from a doctor',
          example: 'Take the prescription to the pharmacy.',
        ),
        StudyCardData(
          term: 'diagnosis',
          definition: 'the identification of an illness',
          example: 'The diagnosis came after a blood test.',
        ),
        StudyCardData(
          term: 'treatment',
          definition: 'medical care given to improve a condition',
          example: 'The treatment lasts for two weeks.',
        ),
        StudyCardData(
          term: 'appointment',
          definition: 'an arranged time to see a doctor',
          example: 'My appointment is tomorrow morning.',
        ),
        StudyCardData(
          term: 'recovery',
          definition: 'the process of becoming healthy again',
          example: 'Sleep is important for recovery.',
        ),
      ],
    ),
  ];

  static List<StudySetData> get favoriteSets =>
      sets.where((set) => set.isFavorite).toList();

  static List<ActivityData> get recentActivity => const [
    ActivityData(
      title: 'Flashcards: Tu vung Kinh doanh',
      subtitle: '6 cards reviewed, 4 known instantly',
      when: '10 minutes ago',
      route: '/flashcard/1',
      icon: Icons.style_outlined,
      color: Color(0xFF4255FF),
    ),
    ActivityData(
      title: 'Quiz: Du lich Anh ngu',
      subtitle: 'Score 5/6 with 83% accuracy',
      when: '1 hour ago',
      route: '/quiz/3',
      icon: Icons.fact_check_outlined,
      color: Color(0xFF26C6DA),
    ),
    ActivityData(
      title: 'Match: Cong nghe va IT',
      subtitle: 'Completed in 1m 48s',
      when: 'Yesterday',
      route: '/match/2',
      icon: Icons.grid_view_rounded,
      color: Color(0xFFFF6B6B),
    ),
    ActivityData(
      title: 'Write: Y te va Suc khoe',
      subtitle: '4 correct answers in a row',
      when: 'Yesterday',
      route: '/write/6',
      icon: Icons.edit_note_outlined,
      color: Color(0xFFE91E63),
    ),
  ];

  static StudySetData findSet(String id) {
    for (final set in sets) {
      if (set.id == id) {
        return set;
      }
    }

    return _fallbackSet(id);
  }

  static List<String> buildQuizOptions(StudySetData set, int questionIndex) {
    final question = set.cards[questionIndex];
    final optionPool = <String>{question.definition};

    for (final card in set.cards) {
      optionPool.add(card.definition);
      if (optionPool.length == 4) {
        break;
      }
    }

    while (optionPool.length < 4) {
      optionPool.add('Meaning for ${question.term} ${optionPool.length}');
    }

    final options = optionPool.toList();
    options.shuffle(Random(question.term.hashCode));
    return options;
  }

  static StudySetData _fallbackSet(String id) {
    final colors = [
      const Color(0xFF4255FF),
      const Color(0xFF26C6DA),
      const Color(0xFFFF6B6B),
      const Color(0xFF43A047),
    ];
    final color = colors[id.hashCode.abs() % colors.length];

    return StudySetData(
      id: id,
      title: 'Study set $id',
      description: 'A generated study set used when a set is not in mock data.',
      author: 'Codex Demo',
      emoji: '📘',
      accentColor: color,
      isFavorite: false,
      learnedCount: 1,
      tags: const ['generated', 'practice'],
      cards: List.generate(
        6,
        (index) => StudyCardData(
          term: 'Term ${index + 1}',
          definition: 'Definition ${index + 1} for generated set $id',
          example: 'Example sentence ${index + 1} for set $id.',
        ),
      ),
    );
  }
}
