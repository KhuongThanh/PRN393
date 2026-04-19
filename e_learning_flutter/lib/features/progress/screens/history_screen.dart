import 'package:flutter/material.dart';

import '../../../core/models/api_models.dart';
import '../../../core/services/study_api_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  static const Color qBlue = Color(0xFF4255FF);
  static const Color qDark = Color(0xFF2E3856);
  static const Color qGray = Color(0xFF939BB4);

  final StudyApiService _studyApiService = StudyApiService();
  late Future<List<StudyHistoryItemData>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _historyFuture = _studyApiService.getStudyHistory();
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
          'Recent activity',
          style: TextStyle(
            color: qDark,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: SafeArea(
        child: FutureBuilder<List<StudyHistoryItemData>>(
          future: _historyFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError || !snapshot.hasData) {
              return _buildErrorState();
            }

            final history = snapshot.data!;

            if (history.isEmpty) {
              return _buildEmptyState();
            }

            final totalReviewed = history.fold<int>(
              0,
              (sum, item) => sum + item.reviewedCount,
            );
            final averageCompletion = history.isEmpty
                ? 0
                : history
                          .map((item) => item.completionRate)
                          .reduce((a, b) => a + b) /
                      history.length;

            return RefreshIndicator(
              onRefresh: () async {
                final future = _studyApiService.getStudyHistory();
                setState(() => _historyFuture = future);
                await future;
              },
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _metric('${history.length}', 'sessions'),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _metric('$totalReviewed', 'reviewed words'),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _metric(
                            '${(averageCompletion * 100).round()}%',
                            'avg completion',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...history.map(_buildHistoryCard),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHistoryCard(StudyHistoryItemData item) {
    final route = item.topicId == null ? null : '/topics/${item.topicId}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: route == null ? null : () => Navigator.pushNamed(context, route),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F2FF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  item.sessionType.toLowerCase() == 'flashcard'
                      ? Icons.style_outlined
                      : Icons.history,
                  color: qBlue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.topicName?.trim().isNotEmpty == true
                          ? item.topicName!
                          : item.sourceName?.trim().isNotEmpty == true
                          ? item.sourceName!
                          : item.sessionType,
                      style: const TextStyle(
                        fontSize: 14,
                        color: qDark,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${item.sessionType} · ${item.reviewedCount}/${item.totalWords} reviewed',
                      style: const TextStyle(fontSize: 12, color: qGray),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        minHeight: 6,
                        value: item.completionRate.clamp(0, 1),
                        backgroundColor: const Color(0xFFECEEF5),
                        valueColor: const AlwaysStoppedAnimation<Color>(qBlue),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _historySubtitle(item),
                      style: const TextStyle(
                        fontSize: 11,
                        color: qGray,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              if (route != null)
                const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(Icons.chevron_right, color: qGray),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _metric(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FE),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              color: qBlue,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              color: qGray,
              fontWeight: FontWeight.w700,
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
            Icon(Icons.history_toggle_off, size: 42, color: qBlue),
            SizedBox(height: 12),
            Text(
              'No study history yet',
              style: TextStyle(
                fontSize: 22,
                color: qDark,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Completed flashcard sessions will appear here once you start studying through the API-backed flows.',
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
              'Unable to load history',
              style: TextStyle(
                fontSize: 22,
                color: qDark,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'The app could not fetch study session history from the API.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: qGray, height: 1.5),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: () {
                setState(
                  () => _historyFuture = _studyApiService.getStudyHistory(),
                );
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

  String _historySubtitle(StudyHistoryItemData item) {
    final duration = item.durationSeconds == null
        ? 'duration unavailable'
        : '${item.durationSeconds}s';

    return '${item.rememberedCount} remembered · ${item.notRememberedCount} missed · $duration';
  }
}
