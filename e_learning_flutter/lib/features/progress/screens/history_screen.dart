import 'package:flutter/material.dart';

import '../../../core/mock/study_mock_data.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  static const Color qBlue = Color(0xFF4255FF);
  static const Color qDark = Color(0xFF2E3856);
  static const Color qGray = Color(0xFF939BB4);

  @override
  Widget build(BuildContext context) {
    final activities = StudyMockData.recentActivity;

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
                  Expanded(child: _metric('4', 'sessions done')),
                  const SizedBox(width: 12),
                  Expanded(child: _metric('88', 'terms reviewed')),
                  const SizedBox(width: 12),
                  Expanded(child: _metric('92%', 'avg accuracy')),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Timeline',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: qDark,
              ),
            ),
            const SizedBox(height: 12),
            ...activities.map(
              (activity) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GestureDetector(
                  onTap: () => Navigator.pushNamed(context, activity.route),
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
                            color: activity.color.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(activity.icon, color: activity.color),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                activity.title,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: qDark,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                activity.subtitle,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: qGray,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                activity.when,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: activity.color,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: qGray),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
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
}
