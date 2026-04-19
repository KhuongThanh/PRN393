import 'package:flutter/foundation.dart';

import '../models/api_models.dart';

enum StudySyncEventType { idle, favoriteChanged, profileUpdated }

class StudySyncEvent {
  const StudySyncEvent._({
    required this.revision,
    required this.type,
    this.wordId,
    this.isFavorite,
    this.user,
  });

  const StudySyncEvent.idle()
    : this._(revision: 0, type: StudySyncEventType.idle);

  const StudySyncEvent.favoriteChanged({
    required int revision,
    required String wordId,
    required bool isFavorite,
  }) : this._(
         revision: revision,
         type: StudySyncEventType.favoriteChanged,
         wordId: wordId,
         isFavorite: isFavorite,
       );

  const StudySyncEvent.profileUpdated({
    required int revision,
    required CurrentUserData user,
  }) : this._(
         revision: revision,
         type: StudySyncEventType.profileUpdated,
         user: user,
       );

  final int revision;
  final StudySyncEventType type;
  final String? wordId;
  final bool? isFavorite;
  final CurrentUserData? user;

  int get favoriteDelta {
    if (type != StudySyncEventType.favoriteChanged || isFavorite == null) {
      return 0;
    }
    return isFavorite! ? 1 : -1;
  }
}

class StudySyncService {
  StudySyncService._();

  static final StudySyncService instance = StudySyncService._();

  final ValueNotifier<StudySyncEvent> events = ValueNotifier(
    const StudySyncEvent.idle(),
  );

  int _revision = 0;

  void notifyFavoriteChanged({
    required String wordId,
    required bool isFavorite,
  }) {
    _revision += 1;
    events.value = StudySyncEvent.favoriteChanged(
      revision: _revision,
      wordId: wordId,
      isFavorite: isFavorite,
    );
  }

  void notifyProfileUpdated(CurrentUserData user) {
    _revision += 1;
    events.value = StudySyncEvent.profileUpdated(
      revision: _revision,
      user: user,
    );
  }
}
