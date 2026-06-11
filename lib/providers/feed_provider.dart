import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../models/opportunity.dart';
import '../models/user.dart';
import '../services/database_service.dart';
import '../services/match_score_service.dart';

class FeedProvider extends ChangeNotifier {
  final DatabaseService _db;
  final MatchScoreService _scorer = MatchScoreService();

  List<Opportunity> _all = [];
  String _filter = 'All';
  String _search = '';
  bool _isLoading = false;

  FeedProvider(this._db);

  List<Opportunity> get all => _all;
  String get filter => _filter;
  bool get isLoading => _isLoading;

  List<Opportunity> get filtered {
    var list = _filter == 'All'
        ? _all
        : _all.where((o) => o.category == _filter).toList();
    if (_search.isNotEmpty) {
      final q = _search.toLowerCase();
      list = list
          .where((o) =>
              o.title.toLowerCase().contains(q) ||
              o.organizer.toLowerCase().contains(q) ||
              o.tags.any((t) => t.toLowerCase().contains(q)))
          .toList();
    }
    return list;
  }

  List<Opportunity> get topMatches {
    final sorted = [..._all]
      ..sort((a, b) => b.matchScore.compareTo(a.matchScore));
    return sorted.take(5).toList();
  }

  List<Opportunity> get upcomingOnly =>
      _all.where((o) => !o.isPast).toList();

  Future<void> loadFeed(AppUser? user) async {
    _isLoading = true;
    notifyListeners();
    try {
      _all = await _db.getOpportunities();
      if (user != null) _scoreAll(user);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _scoreAll(AppUser user) {
    final pastCats = MockData.opportunities
        .where((o) => o.isPast)
        .map((o) => o.category.toLowerCase())
        .toSet();

    for (final opp in _all) {
      opp.matchScore = _scorer.calculateScore(opp, user, pastCategories: pastCats);
    }
  }

  void setFilter(String f) {
    _filter = f;
    notifyListeners();
  }

  void setSearch(String q) {
    _search = q;
    notifyListeners();
  }

  Future<void> addOpportunity(Opportunity opp) async {
    await _db.insertOpportunity(opp);
    _all.insert(0, opp);
    notifyListeners();
  }

  Opportunity? findById(String id) {
    try {
      return _all.firstWhere((o) => o.id == id);
    } catch (_) {
      return null;
    }
  }
}
