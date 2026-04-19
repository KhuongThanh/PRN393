import 'package:flutter/material.dart';

import '../../../core/models/api_models.dart';
import '../../../core/services/study_api_service.dart';
import '../../../core/services/study_sync_service.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  static const Color qBlue = Color(0xFF4255FF);
  static const Color qDark = Color(0xFF2E3856);
  static const Color qGray = Color(0xFF939BB4);

  final StudyApiService _studyApiService = StudyApiService();
  List<FavoriteWordData> _favorites = const [];
  bool _isLoading = true;
  String? _errorMessage;
  final Set<String> _pendingWordIds = <String>{};

  @override
  void initState() {
    super.initState();
    _loadFavorites();
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
          'Favorites',
          style: TextStyle(
            color: qDark,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _favorites.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_favorites.isEmpty && _errorMessage != null) {
      return _buildErrorState(_errorMessage!);
    }

    if (_favorites.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () => _loadFavorites(showLoading: false),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
        itemCount: _favorites.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(
                '${_favorites.length} favorite words synced from the API. Tap the heart to remove one instantly or open a topic to keep studying.',
                style: const TextStyle(fontSize: 13, color: qDark, height: 1.5),
              ),
            );
          }

          final item = _favorites[index - 1];
          return _buildFavoriteCard(item);
        },
      ),
    );
  }

  Widget _tag(String text, {Color color = qGray}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F2FF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildFavoriteCard(FavoriteWordData item) {
    final topicRoute = item.topicId == null ? null : '/topics/${item.topicId}';
    final isRemoving = _pendingWordIds.contains(item.wordId);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
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
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF2F2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.favorite, color: Color(0xFFFF6B6B)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.wordText,
                    style: const TextStyle(
                      fontSize: 15,
                      color: qDark,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.meaning,
                    style: const TextStyle(
                      fontSize: 13,
                      color: qDark,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (item.partOfSpeech?.trim().isNotEmpty == true)
                        _tag(item.partOfSpeech!),
                      if (item.phonetic?.trim().isNotEmpty == true)
                        _tag(item.phonetic!),
                      if (item.topicName?.trim().isNotEmpty == true &&
                          topicRoute != null)
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(context, topicRoute),
                          child: _tag(item.topicName!, color: qBlue),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: isRemoving ? null : () => _removeFavorite(item),
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF2F2),
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: isRemoving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.favorite, color: Color(0xFFFF6B6B)),
              ),
            ),
          ],
        ),
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
            Icon(Icons.favorite_border, size: 42, color: qBlue),
            SizedBox(height: 12),
            Text(
              'No favorites yet',
              style: TextStyle(
                fontSize: 22,
                color: qDark,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Favorite words will appear here once you save them from study flows.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: qGray, height: 1.5),
            ),
          ],
        ),
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
              'Unable to load favorites',
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
                _loadFavorites();
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

  Future<void> _loadFavorites({bool showLoading = true}) async {
    if (showLoading) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final favorites = await _studyApiService.getFavorites();
      if (!mounted) {
        return;
      }

      setState(() {
        _favorites = favorites;
        _errorMessage = null;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      final message = _errorText(
        error,
        fallback: 'The app could not fetch favorite words from the API.',
      );
      if (_favorites.isNotEmpty) {
        setState(() => _isLoading = false);
        _showMessage(message);
        return;
      }

      setState(() {
        _errorMessage = message;
        _isLoading = false;
      });
    }
  }

  Future<void> _removeFavorite(FavoriteWordData item) async {
    if (_pendingWordIds.contains(item.wordId)) {
      return;
    }

    final previousFavorites = List<FavoriteWordData>.from(_favorites);
    setState(() {
      _pendingWordIds.add(item.wordId);
      _favorites = _favorites
          .where((favorite) => favorite.wordId != item.wordId)
          .toList();
    });

    try {
      await _studyApiService.removeFavorite(item.wordId);
      if (!mounted) {
        return;
      }
      StudySyncService.instance.notifyFavoriteChanged(
        wordId: item.wordId,
        isFavorite: false,
      );
      _showMessage('"${item.wordText}" was removed from favorites.');
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() => _favorites = previousFavorites);
      _showMessage(
        _errorText(
          error,
          fallback: 'Unable to remove this favorite right now.',
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _pendingWordIds.remove(item.wordId));
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
}
