import 'package:flutter/material.dart';

class TopicsScreen extends StatefulWidget {
  const TopicsScreen({super.key});

  @override
  State<TopicsScreen> createState() => _TopicsScreenState();
}

class _TopicsScreenState extends State<TopicsScreen> {
  static const Color qBlue = Color(0xFF4255FF);
  static const Color qDark = Color(0xFF2E3856);
  static const Color qGray = Color(0xFF939BB4);

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  String search = '';
  LibraryTab tab = LibraryTab.mine;
  bool focused = false;

  List<TopicSet> sets = [
    TopicSet(
      id: '1',
      title: 'Từ vựng Kinh doanh',
      count: 45,
      learned: 28,
      author: 'Nguyễn Văn A',
      shared: true,
      colorBar: const Color(0xFF4255FF),
      emoji: '💼',
      imageUrl:
          'https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?w=300&q=80',
    ),
    TopicSet(
      id: '2',
      title: 'Công nghệ & IT',
      count: 38,
      learned: 15,
      author: 'Nguyễn Văn A',
      shared: false,
      colorBar: const Color(0xFFFF6B6B),
      emoji: '💻',
      imageUrl:
          'https://images.unsplash.com/photo-1518770660439-4636190af475?w=300&q=80',
    ),
    TopicSet(
      id: '3',
      title: 'Du lịch Anh ngữ',
      count: 52,
      learned: 40,
      author: 'Nguyễn Văn A',
      shared: true,
      colorBar: const Color(0xFF26C6DA),
      emoji: '✈️',
      imageUrl:
          'https://images.unsplash.com/photo-1488085061387-422e29b40080?w=300&q=80',
    ),
    TopicSet(
      id: '4',
      title: 'Ẩm thực & Đồ uống',
      count: 30,
      learned: 10,
      author: 'Nguyễn Văn A',
      shared: false,
      colorBar: const Color(0xFF43A047),
      emoji: '🍜',
      imageUrl:
          'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=300&q=80',
    ),
    TopicSet(
      id: '5',
      title: 'Thể thao quốc tế',
      count: 41,
      learned: 0,
      author: 'Nguyễn Văn A',
      shared: false,
      colorBar: const Color(0xFFFB8C00),
      emoji: '⚽',
      imageUrl:
          'https://images.unsplash.com/photo-1517466787929-bc90951d0974?w=300&q=80',
    ),
    TopicSet(
      id: '6',
      title: 'Y tế & Sức khoẻ',
      count: 36,
      learned: 5,
      author: 'Nguyễn Văn A',
      shared: true,
      colorBar: const Color(0xFFE91E63),
      emoji: '🏥',
      imageUrl:
          'https://images.unsplash.com/photo-1505751172876-fa1923c5c528?w=300&q=80',
    ),
  ];

  final List<SuggestedSet> suggested = const [
    SuggestedSet(
      title: 'IELTS Academic',
      count: 200,
      author: 'Quizlet Official',
      stars: '4.8k',
    ),
    SuggestedSet(
      title: 'TOEIC 900+',
      count: 150,
      author: 'English Pro',
      stars: '3.2k',
    ),
    SuggestedSet(
      title: 'Giao tiếp hằng ngày',
      count: 120,
      author: 'Daily English',
      stars: '6.1k',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _searchFocus.addListener(() {
      setState(() {
        focused = _searchFocus.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  List<TopicSet> get filteredSets {
    final keyword = search.trim().toLowerCase();
    if (keyword.isEmpty) return sets;
    return sets.where((s) => s.title.toLowerCase().contains(keyword)).toList();
  }

  void _go(String route) {
    Navigator.pushNamed(context, route);
  }

  Future<void> _openCreateSheet() async {
    final result = await showModalBottomSheet<TopicSet>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _CreateTopicSheet(),
    );

    if (result == null) return;

    setState(() {
      sets = [result, ...sets];
    });

    if (!mounted) return;
    Navigator.pushNamed(context, '/topics/${result.id}');
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F7FB),
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (tab == LibraryTab.mine) _buildMineTab(),
                      if (tab == LibraryTab.classes) _buildClassesTab(),
                      if (tab == LibraryTab.explore) _buildExploreTab(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Thư viện',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: qDark,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _openCreateSheet,
                  child: Container(
                    height: 36,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: qBlue,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.add, size: 16, color: Colors.white),
                        SizedBox(width: 6),
                        Text(
                          'Tạo mới',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: focused
                    ? const Color(0xFFF0F2FF)
                    : const Color(0xFFF6F7FB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: focused ? qBlue : const Color(0xFFECEEF5),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.search,
                    size: 16,
                    color: focused ? qBlue : qGray,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocus,
                      onChanged: (value) {
                        setState(() => search = value);
                      },
                      decoration: const InputDecoration(
                        hintText: 'Tìm học phần...',
                        hintStyle: TextStyle(
                          color: qGray,
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        isCollapsed: true,
                      ),
                      style: const TextStyle(
                        color: qDark,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Color(0xFFECEEF5),
                  width: 1.5,
                ),
              ),
            ),
            child: Row(
              children: [
                _buildTabButton('Của tôi', LibraryTab.mine),
                _buildTabButton('Lớp học', LibraryTab.classes),
                _buildTabButton('Khám phá', LibraryTab.explore),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, LibraryTab value) {
    final isActive = tab == value;

    return GestureDetector(
      onTap: () {
        setState(() => tab = value);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? qBlue : Colors.transparent,
              width: 2.5,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
            color: isActive ? qBlue : qGray,
          ),
        ),
      ),
    );
  }

  Widget _buildMineTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${filteredSets.length} HỌC PHẦN',
          style: const TextStyle(
            fontSize: 11,
            color: qGray,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        ...filteredSets.map((set) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildTopicCard(set),
            )),
      ],
    );
  }

  Widget _buildTopicCard(TopicSet set) {
    final pct = set.count > 0 ? ((set.learned / set.count) * 100).round() : 0;

    return GestureDetector(
      onTap: () => _go('/topics/${set.id}'),
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
            if (set.imageUrl.isNotEmpty)
              SizedBox(
                height: 56,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: Image.network(
                          set.imageUrl,
                          fit: BoxFit.cover,
                          color: Colors.black.withOpacity(0.15),
                          colorBlendMode: BlendMode.darken,
                          errorBuilder: (_, __, ___) {
                            return Container(
                              color: set.colorBar.withOpacity(0.18),
                            );
                          },
                        ),
                      ),
                    ),
                    Container(
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            set.colorBar.withOpacity(0.75),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 12,
                      top: 10,
                      right: 12,
                      child: Row(
                        children: [
                          Text(
                            set.emoji,
                            style: const TextStyle(fontSize: 18),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              set.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          if (set.shared) _sharedChip(onDark: true),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                height: 4,
                decoration: BoxDecoration(
                  color: set.colorBar,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (set.imageUrl.isEmpty) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: set.colorBar.withOpacity(0.10),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            set.emoji,
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  set.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: qDark,
                                  ),
                                ),
                              ),
                              if (set.shared) ...[
                                const SizedBox(width: 8),
                                _sharedChip(onDark: false),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                  Text(
                    '${set.count} thuật ngữ · ${set.author}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: qGray,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (set.learned > 0)
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: LinearProgressIndicator(
                              minHeight: 4,
                              value: pct / 100,
                              backgroundColor: const Color(0xFFECEEF5),
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(set.colorBar),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$pct%',
                          style: const TextStyle(
                            fontSize: 11,
                            color: qGray,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    )
                  else
                    Row(
                      children: const [
                        Icon(Icons.menu_book_outlined,
                            size: 12, color: qGray),
                        SizedBox(width: 6),
                        Text(
                          'Chưa bắt đầu học',
                          style: TextStyle(
                            fontSize: 11,
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
    );
  }

  Widget _sharedChip({required bool onDark}) {
    final bg = onDark
        ? Colors.white.withOpacity(0.20)
        : const Color(0xFFF0F2FF);
    final fg = onDark ? Colors.white : qBlue;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.group_outlined, size: 10, color: fg),
          const SizedBox(width: 3),
          Text(
            'Chia sẻ',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassesTab() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFF0F2FF),
                borderRadius: BorderRadius.circular(24),
              ),
              alignment: Alignment.center,
              child: const Text(
                '🏫',
                style: TextStyle(fontSize: 36),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Chưa có lớp học nào',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: qDark,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Tham gia lớp học để học cùng bạn bè',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: qGray,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: qBlue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Tham gia lớp học',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExploreTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'GỢI Ý CHO BẠN',
          style: TextStyle(
            fontSize: 11,
            color: qGray,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        ...suggested.map(
          (s) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GestureDetector(
              onTap: () => _go('/topics/1'),
              child: Container(
                padding: const EdgeInsets.all(16),
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
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F2FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.book_outlined,
                        size: 22,
                        color: qBlue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s.title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: qDark,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${s.count} thuật ngữ · ${s.author}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: qGray,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '★ ${s.stars} đã học',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFFFFCD1F),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      size: 16,
                      color: Color(0xFFECEEF5),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

enum LibraryTab { mine, classes, explore }

class TopicSet {
  final String id;
  final String title;
  final int count;
  final int learned;
  final String author;
  final bool shared;
  final Color colorBar;
  final String emoji;
  final String imageUrl;

  const TopicSet({
    required this.id,
    required this.title,
    required this.count,
    required this.learned,
    required this.author,
    required this.shared,
    required this.colorBar,
    required this.emoji,
    required this.imageUrl,
  });
}

class SuggestedSet {
  final String title;
  final int count;
  final String author;
  final String stars;

  const SuggestedSet({
    required this.title,
    required this.count,
    required this.author,
    required this.stars,
  });
}

class _CreateTopicSheet extends StatefulWidget {
  const _CreateTopicSheet();

  @override
  State<_CreateTopicSheet> createState() => _CreateTopicSheetState();
}

class _CreateTopicSheetState extends State<_CreateTopicSheet> {
  static const Color qBlue = Color(0xFF4255FF);
  static const Color qDark = Color(0xFF2E3856);
  static const Color qGray = Color(0xFF939BB4);

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descController = TextEditingController();

  String newEmoji = '📚';

  final emojis = const ['📚', '💼', '💻', '✈️', '🍜', '⚽', '🏥', '🎵', '🔬', '🌍'];

  @override
  void dispose() {
    titleController.dispose();
    descController.dispose();
    super.dispose();
  }

  void _submit() {
    final title = titleController.text.trim();
    if (title.isEmpty) return;

    final newSet = TopicSet(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      count: 0,
      learned: 0,
      author: 'Nguyễn Văn A',
      shared: false,
      colorBar: qBlue,
      emoji: newEmoji,
      imageUrl: '',
    );

    Navigator.pop(context, newSet);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Tạo học phần mới',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: qDark,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF6F7FB),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 16,
                      color: qGray,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'BIỂU TƯỢNG',
                style: TextStyle(
                  fontSize: 11,
                  color: qGray,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: emojis.map((e) {
                final selected = newEmoji == e;
                return GestureDetector(
                  onTap: () {
                    setState(() => newEmoji = e);
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFFF0F2FF)
                          : const Color(0xFFF6F7FB),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected ? qBlue : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      e,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'TÊN HỌC PHẦN *',
                style: TextStyle(
                  fontSize: 11,
                  color: qGray,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: titleController,
              autofocus: true,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Ví dụ: Từ vựng IELTS...',
                hintStyle: const TextStyle(
                  color: qGray,
                  fontSize: 14,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: titleController.text.trim().isNotEmpty
                        ? qBlue
                        : const Color(0xFFECEEF5),
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: qBlue, width: 1.5),
                ),
              ),
              style: const TextStyle(
                color: qDark,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'MÔ TẢ (tÙy chọn)',
                style: TextStyle(
                  fontSize: 11,
                  color: qGray,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: descController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Mô tả ngắn về học phần này...',
                hintStyle: const TextStyle(
                  color: qGray,
                  fontSize: 13,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xFFECEEF5), width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: qBlue, width: 1.5),
                ),
              ),
              style: const TextStyle(
                color: qDark,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: titleController.text.trim().isEmpty ? null : _submit,
              child: Container(
                height: 52,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: titleController.text.trim().isEmpty
                      ? const Color(0xFFECEEF5)
                      : qBlue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check,
                      size: 18,
                      color: titleController.text.trim().isEmpty
                          ? qGray
                          : Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Tạo học phần',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: titleController.text.trim().isEmpty
                            ? qGray
                            : Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}