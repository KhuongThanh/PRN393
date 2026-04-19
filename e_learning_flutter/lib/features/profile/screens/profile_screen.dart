import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/routes.dart';
import '../../../core/models/api_models.dart';
import '../../../core/services/study_api_service.dart';
import '../../../core/services/study_sync_service.dart';
import '../../auth/providers/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const Color qBlue = Color(0xFF4255FF);
  static const Color qDark = Color(0xFF2E3856);
  static const Color qGray = Color(0xFF939BB4);

  final StudyApiService _studyApiService = StudyApiService();
  final StudySyncService _studySyncService = StudySyncService.instance;
  _ProfileBundle? _profileData;
  String? _errorMessage;
  bool _isLoading = true;
  bool _isSavingProfile = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _studySyncService.events.addListener(_handleSyncEvent);
  }

  @override
  void dispose() {
    _studySyncService.events.removeListener(_handleSyncEvent);
    super.dispose();
  }

  Future<_ProfileBundle> _fetchProfile() async {
    final user = await _studyApiService.getCurrentUser();
    final progress = await _studyApiService.getProgressSummary();
    final dashboard = await _studyApiService.getDashboard();

    return _ProfileBundle(user: user, progress: progress, dashboard: dashboard);
  }

  Future<bool> _loadProfile({bool showLoading = true}) async {
    if (showLoading) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final bundle = await _fetchProfile();
      if (!mounted) {
        return false;
      }

      setState(() {
        _profileData = bundle;
        _errorMessage = null;
        _isLoading = false;
      });
      return true;
    } catch (error) {
      if (!mounted) {
        return false;
      }

      final message = _errorText(
        error,
        fallback: 'The app could not fetch account data from the API.',
      );
      if (_profileData != null) {
        setState(() => _isLoading = false);
        _showMessage(message);
        return false;
      }

      setState(() {
        _errorMessage = message;
        _isLoading = false;
      });
      return false;
    }
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
          'Profile',
          style: TextStyle(
            color: qDark,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: SafeArea(child: _buildBody(context)),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading && _profileData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_profileData == null) {
      return _buildErrorState(
        _errorMessage ?? 'The app could not fetch account data from the API.',
      );
    }

    final data = _profileData!;
    return RefreshIndicator(
      onRefresh: () => _loadProfile(showLoading: false),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
        children: [
          _buildHero(data.user, data.dashboard),
          _buildStats(data.progress),
          _buildAccountCard(data.user),
          const SizedBox(height: 16),
          _buildLogoutButton(context),
        ],
      ),
    );
  }

  Widget _buildHero(CurrentUserData user, DashboardData dashboard) {
    final displayName = user.fullName?.trim().isNotEmpty == true
        ? user.fullName!.trim()
        : user.userName;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [qBlue, qDark],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          Container(
            width: 86,
            height: 86,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(28),
            ),
            alignment: Alignment.center,
            child: Text(
              _initials(displayName),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            displayName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            user.email,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.76),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _heroMetric(
                  value: '${dashboard.learnedTopicCount}',
                  label: 'topics learned',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _heroMetric(
                  value: '${dashboard.learnedWordCount}',
                  label: 'words learned',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _heroMetric(
                  value: '${dashboard.favoriteWordCount}',
                  label: 'favorite words',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStats(ProgressSummaryData progress) {
    final attempts = progress.totalCorrectCount + progress.totalIncorrectCount;
    final accuracy = attempts == 0
        ? 0
        : ((progress.totalCorrectCount / attempts) * 100).round();

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
            'Learning summary',
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
                child: _statCard(
                  title: 'Completion',
                  value: '${(progress.completionRate * 100).round()}%',
                  subtitle:
                      '${progress.learnedWords}/${progress.totalWords} words',
                  color: qBlue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _statCard(
                  title: 'Accuracy',
                  value: '$accuracy%',
                  subtitle: '${progress.totalCorrectCount} correct',
                  color: const Color(0xFF1DB954),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAccountCard(CurrentUserData user) {
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
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Account details',
                  style: TextStyle(
                    fontSize: 16,
                    color: qDark,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed: _isSavingProfile
                    ? null
                    : () => _showEditProfileDialog(user),
                style: OutlinedButton.styleFrom(
                  foregroundColor: qBlue,
                  side: const BorderSide(color: Color(0xFFDCE1F4)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: _isSavingProfile
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.edit_outlined, size: 18),
                label: Text(_isSavingProfile ? 'Saving' : 'Edit'),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _detailRow('Username', user.userName),
          _detailRow('Email', user.email),
          _detailRow(
            'Full name',
            user.fullName?.trim().isNotEmpty == true
                ? user.fullName!
                : 'Not set',
          ),
          _detailRow('Target daily words', '${user.targetDailyWords}'),
          _detailRow('Status', user.isActive ? 'Active' : 'Inactive'),
          _detailRow(
            'Roles',
            user.roles.isEmpty ? 'None' : user.roles.join(', '),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        await context.read<AuthProvider>().logout();
        if (!context.mounted) {
          return;
        }
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.login,
          (route) => false,
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: qDark,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(54),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: const Text(
        'Log out',
        style: TextStyle(fontWeight: FontWeight.w800),
      ),
    );
  }

  Widget _heroMetric({required String value, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.72),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard({
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

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: qGray,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                color: qDark,
                fontWeight: FontWeight.w700,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 42, color: qBlue),
            const SizedBox(height: 12),
            const Text(
              'Unable to load profile',
              style: TextStyle(
                fontSize: 22,
                color: qDark,
                fontWeight: FontWeight.w900,
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
              onPressed: () {
                _loadProfile();
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

  Future<void> _showEditProfileDialog(CurrentUserData user) async {
    final formKey = GlobalKey<FormState>();
    final fullNameController = TextEditingController(text: user.fullName ?? '');
    final targetController = TextEditingController(
      text: '${user.targetDailyWords}',
    );

    final result = await showDialog<_ProfileEditFormValue>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Edit profile'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: fullNameController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Full name',
                    hintText: 'Enter your full name',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your full name.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: targetController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Daily target',
                    hintText: 'Words per day',
                  ),
                  validator: (value) {
                    final parsed = int.tryParse(value?.trim() ?? '');
                    if (parsed == null || parsed <= 0) {
                      return 'Enter a number greater than 0.';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) {
                  return;
                }

                Navigator.pop(
                  dialogContext,
                  _ProfileEditFormValue(
                    fullName: fullNameController.text.trim(),
                    targetDailyWords: int.parse(targetController.text.trim()),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: qBlue,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    fullNameController.dispose();
    targetController.dispose();

    if (!mounted || result == null) {
      return;
    }

    setState(() => _isSavingProfile = true);
    try {
      final updatedUser = await _studyApiService.updateProfile(
        fullName: result.fullName,
        targetDailyWords: result.targetDailyWords,
      );
      _studySyncService.notifyProfileUpdated(updatedUser);
      final refreshed = await _loadProfile(showLoading: false);
      if (!mounted) {
        return;
      }
      _showMessage(
        refreshed
            ? 'Profile updated successfully.'
            : 'Profile saved. Pull to refresh if the latest stats are not visible yet.',
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      _showMessage(
        _errorText(error, fallback: 'Unable to update your profile right now.'),
      );
    } finally {
      if (mounted) {
        setState(() => _isSavingProfile = false);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String _errorText(Object error, {required String fallback}) {
    if (error is ApiException && error.message.trim().isNotEmpty) {
      return error.message;
    }
    return fallback;
  }

  void _handleSyncEvent() {
    final currentData = _profileData;
    if (!mounted || currentData == null) {
      return;
    }

    final event = _studySyncService.events.value;
    if (event.type == StudySyncEventType.favoriteChanged) {
      final nextCount = _safeCount(
        currentData.dashboard.favoriteWordCount + event.favoriteDelta,
      );
      setState(() {
        _profileData = _ProfileBundle(
          user: currentData.user,
          progress: currentData.progress,
          dashboard: currentData.dashboard.copyWith(
            favoriteWordCount: nextCount,
          ),
        );
      });
      return;
    }

    if (event.type == StudySyncEventType.profileUpdated && event.user != null) {
      setState(() {
        _profileData = _ProfileBundle(
          user: event.user!,
          progress: currentData.progress,
          dashboard: currentData.dashboard.copyWith(
            targetDailyWords: event.user!.targetDailyWords,
          ),
        );
      });
    }
  }

  int _safeCount(int value) => value < 0 ? 0 : value;

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

class _ProfileBundle {
  const _ProfileBundle({
    required this.user,
    required this.progress,
    required this.dashboard,
  });

  final CurrentUserData user;
  final ProgressSummaryData progress;
  final DashboardData dashboard;
}

class _ProfileEditFormValue {
  const _ProfileEditFormValue({
    required this.fullName,
    required this.targetDailyWords,
  });

  final String fullName;
  final int targetDailyWords;
}
