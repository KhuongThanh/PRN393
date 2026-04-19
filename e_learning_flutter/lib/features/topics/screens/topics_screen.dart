import 'package:flutter/material.dart';

import '../../../core/models/api_models.dart';
import '../../../core/services/study_api_service.dart';

class TopicsScreen extends StatefulWidget {
  const TopicsScreen({super.key});

  @override
  State<TopicsScreen> createState() => _TopicsScreenState();
}

class _TopicsScreenState extends State<TopicsScreen> {
  static const Color qBlue = Color(0xFF4255FF);
  static const Color qDark = Color(0xFF2E3856);
  static const Color qGray = Color(0xFF939BB4);

  final StudyApiService _studyApiService = StudyApiService();
  final TextEditingController _searchController = TextEditingController();

  late Future<List<TopicSummaryData>> _topicsFuture;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _topicsFuture = _studyApiService.getTopics(includeStats: true);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: qDark,
        elevation: 0,
        title: const Text(
          'Topics',
          style: TextStyle(
            color: qDark,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: SafeArea(
        child: FutureBuilder<List<TopicSummaryData>>(
          future: _topicsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError || !snapshot.hasData) {
              return _buildErrorState();
            }

            final topics = snapshot.data!
                .where(
                  (topic) => topic.topicName.toLowerCase().contains(
                    _search.toLowerCase(),
                  ),
                )
                .toList();

            return RefreshIndicator(
              onRefresh: () async {
                final future = _studyApiService.getTopics(includeStats: true);
                setState(() => _topicsFuture = future);
                await future;
              },
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) => setState(() => _search = value),
                      decoration: const InputDecoration(
                        icon: Icon(Icons.search, color: qGray),
                        hintText: 'Search topics from API...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${topics.length} topics available',
                    style: const TextStyle(
                      fontSize: 12,
                      color: qGray,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...topics.map(_buildTopicCard),
                  const SizedBox(height: 8),
                  _buildInfoCard(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTopicCard(TopicSummaryData topic) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, '/topics/${topic.topicId}'),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F2FF),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.menu_book_outlined,
                  color: qBlue,
                  size: 28,
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
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      topic.description?.trim().isNotEmpty == true
                          ? topic.description!
                          : 'No description provided for this topic.',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: qGray,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          '${topic.wordCount} words',
                          style: const TextStyle(
                            fontSize: 11,
                            color: qGray,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '${topic.learnedWords} learned',
                          style: const TextStyle(
                            fontSize: 11,
                            color: qBlue,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        minHeight: 6,
                        value: topic.completionRate.clamp(0, 1),
                        backgroundColor: const Color(0xFFECEEF5),
                        valueColor: const AlwaysStoppedAnimation<Color>(qBlue),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
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
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Icon(Icons.info_outline, color: qBlue),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Topic creation is not wired yet because the backend currently exposes read endpoints for vocabulary topics. Browsing and studying are fully API-driven now.',
              style: TextStyle(fontSize: 12, color: qDark, height: 1.5),
            ),
          ),
        ],
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
              'Unable to load topics',
              style: TextStyle(
                fontSize: 22,
                color: qDark,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'The app could not fetch vocabulary topics from the API. Try again once the backend is reachable.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: qGray, height: 1.5),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _topicsFuture = _studyApiService.getTopics(
                    includeStats: true,
                  );
                });
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
}
