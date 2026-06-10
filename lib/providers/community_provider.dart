import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../models/community.dart';
import '../services/preferences_service.dart';

class CommunityProvider extends ChangeNotifier {
  final PreferencesService _prefs;
  final List<Community> _all = List.from(MockData.communities);
  Set<String> _joinedIds = {};

  CommunityProvider(this._prefs) {
    _loadJoined();
  }

  List<Community> get all => _all;
  Set<String> get joinedIds => _joinedIds;

  List<Community> get joined =>
      _all.where((c) => _joinedIds.contains(c.id)).toList();

  bool isJoined(String id) => _joinedIds.contains(id);

  void _loadJoined() {
    // Seed from mock user's joined communities
    _joinedIds = Set.from(MockData.mockUser.joinedCommunityIds);
  }

  Future<void> toggleJoin(String id) async {
    if (_joinedIds.contains(id)) {
      _joinedIds.remove(id);
    } else {
      _joinedIds.add(id);
    }
    notifyListeners();
  }

  Community? findById(String id) {
    try {
      return _all.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }
}
