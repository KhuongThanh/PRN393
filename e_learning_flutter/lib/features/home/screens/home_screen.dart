import 'package:flutter/material.dart';

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

  bool notifOpen = false;

  final List<Map<String, dynamic>> recentSets = [
    {
      'id': '1',
      'title': 'Từ vựng Kinh doanh',
      'count': 45,
      'author': 'Nguyễn Văn A',
      'learned': 28,
      'color': Color(0xFF4255FF),
    },
    {
      'id': '2',
      'title': 'Công nghệ & IT',
      'count': 38,
      'author': 'Nguyễn Văn A',
      'learned': 15,
      'color': Color(0xFFFF6B6B),
    },
    {
      'id': '3',
      'title': 'Du lịch Anh ngữ',
      'count': 52,
      'author': 'Nguyễn Văn A',
      'learned': 40,
      'color': Color(0xFF26C6DA),
    },
  ];

  late final String lastTopic = recentSets[0]['id'] as String;

  late final List<Map<String, dynamic>> modes = [
    {
      'emoji': '📇',
      'label': 'Thẻ học',
      'sub': 'Flashcard',
      'path': '/flashcard/$lastTopic',
      'bg': const Color(0xFFF0F2FF),
      'color': qBlue,
    },
    {
      'emoji': '📝',
      'label': 'Làm Test',
      'sub': 'Kiểm tra',
      'path': '/quiz/$lastTopic',
      'bg': const Color(0xFFFFF9E6),
      'color': const Color(0xFFC8970A),
    },
    {
      'emoji': '🧩',
      'label': 'Ghép đôi',
      'sub': 'Match',
      'path': '/match/$lastTopic',
      'bg': const Color(0xFFF0FFF4),
      'color': const Color(0xFF1DB954),
    },
    {
      'emoji': '✏️',
      'label': 'Gõ đáp án',
      'sub': 'Write',
      'path': '/write/$lastTopic',
      'bg': const Color(0xFFFFF0F0),
      'color': const Color(0xFFFF6B6B),
    },
  ];

  final List<int> weekBars = [12, 8, 20, 15, 10, 18, 5];
  final List<String> dayLabels = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

  final Map<String, dynamic> wordProgress = {
    'learned': 127,
    'inProgress': 56,
    'notStarted': 197,
    'correctCount': 1240,
    'incorrectCount': 94,
    'targetDailyWords': 20,
    'todayDone': 10,
  };

  int get accuracy {
    final correct = wordProgress['correctCount'] as int;
    final incorrect = wordProgress['incorrectCount'] as int;
    return ((correct / (correct + incorrect)) * 100).round();
  }

  int get maxBar => weekBars.reduce((a, b) => a > b ? a : b);

  double get todayProgressPercent {
    final done = wordProgress['todayDone'] as int;
    final target = wordProgress['targetDailyWords'] as int;
    return target == 0 ? 0 : done / target;
  }

  int get currentWeekdayIndex {
    final weekday = DateTime.now().weekday;
    return weekday - 1;
  }

  void _go(String route) {
    Navigator.pushNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(),
              if (notifOpen) _buildNotificationDropdown(),
              _buildDailyStreakBanner(),
              _buildDailyGoalCard(),
              _buildVocabularyProgressCard(),
              _buildQuickActions(),
              _buildStudyModes(),
              _buildRecentStudySets(),
              _buildWeeklyStats(),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Chào mừng trở lại 👋',
                  style: TextStyle(
                    fontSize: 12,
                    color: qGray,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Xin chào, Văn A!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: qDark,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () => setState(() => notifOpen = !notifOpen),
                child: Stack(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: notifOpen
                            ? const Color(0xFFF0F2FF)
                            : const Color(0xFFF6F7FB),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        notifOpen
                            ? Icons.notifications_active_outlined
                            : Icons.notifications_none,
                        size: 20,
                        color: notifOpen ? qBlue : qDark,
                      ),
                    ),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF6B6B),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _go('/topics'),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: qBlue,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationDropdown() {
    final notifications = [
      {
        'emoji': '🔥',
        'text': 'Bạn có chuỗi 7 ngày học liên tiếp!',
        'time': 'Vừa xong',
        'unread': true,
      },
      {
        'emoji': '🎯',
        'text': 'Đã đạt mục tiêu hôm qua: 20 từ!',
        'time': '1 giờ trước',
        'unread': true,
      },
      {
        'emoji': '📚',
        'text': "Bộ từ mới 'Y tế & Sức khoẻ' vừa được thêm",
        'time': 'Hôm qua',
        'unread': false,
      },
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFECEEF5), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(46, 56, 86, 0.12),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFFECEEF5)),
              ),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    '🔔 Thông báo',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: qDark,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => notifOpen = false),
                  child: const Text(
                    'Đánh dấu đã đọc',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: qBlue,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ...List.generate(notifications.length, (i) {
            final n = notifications[i];
            final unread = n['unread'] as bool;

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: unread ? const Color(0xFFFAFBFF) : Colors.white,
                border: i < notifications.length - 1
                    ? const Border(
                        bottom: BorderSide(color: Color(0xFFF6F7FB)),
                      )
                    : null,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    n['emoji'] as String,
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          n['text'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            color: qDark,
                            fontWeight:
                                unread ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          n['time'] as String,
                          style: const TextStyle(
                            fontSize: 10,
                            color: qGray,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (unread)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: qBlue,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDailyStreakBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: BoxDecoration(
        color: qDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: qYellow,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    '🔥',
                    style: TextStyle(fontSize: 26),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Chuỗi 7 ngày!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Học hôm nay để không mất chuỗi nhé',
                        style: TextStyle(
                          color: Color.fromRGBO(255, 255, 255, 0.55),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => _go('/flashcard/1'),
                  child: Container(
                    height: 38,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: qYellow,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'Học ngay',
                      style: TextStyle(
                        color: qDark,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(7, (i) {
                final active = i < 6;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: active
                              ? qYellow
                              : const Color.fromRGBO(255, 255, 255, 0.08),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          active ? '⚡' : '?',
                          style: TextStyle(
                            fontSize: active ? 13 : 11,
                            color: active ? Colors.black : const Color(0xFF555555),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dayLabels[i],
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: active ? qYellow : const Color(0xFF555555),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyGoalCard() {
    final done = wordProgress['todayDone'] as int;
    final target = wordProgress['targetDailyWords'] as int;
    final remaining = target - done;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.gps_fixed, size: 15, color: qBlue),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Mục tiêu hôm nay',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: qDark,
                  ),
                ),
              ),
              Text(
                '$done / $target từ',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: qBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: todayProgressPercent.clamp(0, 1),
              minHeight: 8,
              backgroundColor: const Color(0xFFECEEF5),
              valueColor: const AlwaysStoppedAnimation(qBlue),
            ),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Còn $remaining từ nữa để đạt mục tiêu hôm nay',
              style: const TextStyle(
                fontSize: 11,
                color: qGray,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVocabularyProgressCard() {
    final learned = wordProgress['learned'] as int;
    final inProgress = wordProgress['inProgress'] as int;
    final notStarted = wordProgress['notStarted'] as int;
    final total = learned + inProgress + notStarted;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.trending_up, size: 15, color: qBlue),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Tiến độ từ vựng',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: qDark,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => _go('/profile'),
                child: const Text(
                  'Chi tiết →',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: qBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: Row(
              children: [
                Expanded(
                  flex: learned,
                  child: Container(height: 10, color: const Color(0xFF1DB954)),
                ),
                Expanded(
                  flex: inProgress,
                  child: Container(height: 10, color: qBlue),
                ),
                Expanded(
                  flex: notStarted == 0 ? 1 : notStarted,
                  child: Container(height: 10, color: const Color(0xFFECEEF5)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _legendItem('Thành thạo', learned, const Color(0xFF1DB954)),
              _legendItem('Đang học', inProgress, qBlue),
              _legendItem('Chưa học', notStarted, qGray),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.only(top: 10),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Color(0xFFECEEF5)),
              ),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Tỉ lệ chính xác (UserWordProgress)',
                    style: TextStyle(
                      fontSize: 11,
                      color: qGray,
                    ),
                  ),
                ),
                Text(
                  '$accuracy%',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1DB954),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendItem(String label, int value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '●',
          style: TextStyle(
            fontSize: 8,
            color: color,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '$label:',
          style: const TextStyle(
            fontSize: 11,
            color: qGray,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '$value',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _go('/favorites'),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0F0),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFECACA), width: 1.5),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.favorite, size: 15, color: Color(0xFFFF6B6B)),
                    SizedBox(width: 8),
                    Text(
                      'Yêu thích',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: qDark,
                      ),
                    ),
                    Spacer(),
                    Text(
                      '6 từ',
                      style: TextStyle(
                        fontSize: 10,
                        color: qGray,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () => _go('/history'),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F2FF),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFC7CFFE), width: 1.5),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.history, size: 15, color: qBlue),
                    SizedBox(width: 8),
                    Text(
                      'Lịch sử',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: qDark,
                      ),
                    ),
                    Spacer(),
                    Text(
                      '5 phiên',
                      style: TextStyle(
                        fontSize: 10,
                        color: qGray,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudyModes() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Chế độ học',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: qDark,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(modes.length, (i) {
              final m = modes[i];
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: i < modes.length - 1 ? 8 : 0),
                  child: GestureDetector(
                    onTap: () => _go(m['path'] as String),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: m['bg'] as Color,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Text(
                            m['emoji'] as String,
                            style: const TextStyle(fontSize: 22),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            m['label'] as String,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: m['color'] as Color,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            m['sub'] as String,
                            style: const TextStyle(
                              fontSize: 9,
                              color: qGray,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentStudySets() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Học gần đây',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: qDark,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => _go('/topics'),
                child: Row(
                  children: const [
                    Text(
                      'Xem tất cả',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: qBlue,
                      ),
                    ),
                    Icon(Icons.chevron_right, size: 14, color: qBlue),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            children: recentSets.map((set) {
              final count = set['count'] as int;
              final learned = set['learned'] as int;
              final pct = ((learned / count) * 100).round();
              final color = set['color'] as Color;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GestureDetector(
                  onTap: () => _go('/topics/${set['id']}'),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromRGBO(46, 56, 86, 0.08),
                          blurRadius: 6,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          set['title'] as String,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w800,
                                            color: qDark,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '$count thuật ngữ · ${set['author']}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: qGray,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => _go('/flashcard/${set['id']}'),
                                    child: Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: color.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.play_arrow,
                                        size: 18,
                                        color: color,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(999),
                                      child: LinearProgressIndicator(
                                        value: learned / count,
                                        minHeight: 5,
                                        backgroundColor: const Color(0xFFECEEF5),
                                        valueColor: AlwaysStoppedAnimation(color),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    '$pct%',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: qGray,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyStats() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Tuần này',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: qDark,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F2FF),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.bolt, size: 12, color: qBlue),
                    SizedBox(width: 4),
                    Text(
                      '88 từ',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: qBlue,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 60,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(weekBars.length, (i) {
                final value = weekBars[i];
                final isToday = i == currentWeekdayIndex;
                final color = isToday
                    ? qBlue
                    : i < 5
                        ? const Color(0xFFECEEF5)
                        : const Color(0xFFF6F7FB);

                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: i < weekBars.length - 1 ? 8 : 0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              height: (value / maxBar) * 48,
                              constraints: const BoxConstraints(minHeight: 4),
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dayLabels[i],
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: i < 5 ? qDark : qGray,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}