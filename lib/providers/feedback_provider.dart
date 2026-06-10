import 'package:flutter/material.dart';

import '../models/feedback.dart';
import '../services/database_service.dart';

class FeedbackProvider extends ChangeNotifier {
  final DatabaseService _db;
  final Map<String, List<EventFeedback>> _cache = {};
  final Set<String> _submitted = {}; // "eventId_userId"

  FeedbackProvider(this._db);

  List<EventFeedback> feedbackFor(String eventId) => _cache[eventId] ?? [];

  Future<void> loadFeedback(String eventId) async {
    _cache[eventId] = await _db.getFeedback(eventId);
    notifyListeners();
  }

  Future<bool> hasSubmitted(String eventId, String userId) async {
    if (_submitted.contains('${eventId}_$userId')) return true;
    return _db.hasUserSubmittedFeedback(eventId, userId);
  }

  Future<void> submitFeedback(EventFeedback fb) async {
    await _db.insertFeedback(fb);
    _submitted.add('${fb.eventId}_${fb.userId}');
    _cache.putIfAbsent(fb.eventId, () => []).add(fb);
    notifyListeners();
  }

  // Analytics helpers
  double averageOverall(String eventId) {
    final list = feedbackFor(eventId);
    if (list.isEmpty) return 0;
    return list.map((f) => f.overallRating).reduce((a, b) => a + b) / list.length;
  }

  Map<int, int> ratingDistribution(String eventId) {
    final dist = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    for (final f in feedbackFor(eventId)) {
      dist[f.overallRating] = (dist[f.overallRating] ?? 0) + 1;
    }
    return dist;
  }

  Map<String, double> categoryAverages(String eventId) {
    final list = feedbackFor(eventId);
    if (list.isEmpty) return {};
    double avg(int Function(EventFeedback) fn) =>
        list.map(fn).reduce((a, b) => a + b) / list.length;
    return {
      'Overall': avg((f) => f.overallRating),
      'Content': avg((f) => f.contentRating),
      'Organization': avg((f) => f.organizationRating),
      'Networking': avg((f) => f.networkingRating),
    };
  }

  double recommendationRate(String eventId) {
    final list = feedbackFor(eventId);
    if (list.isEmpty) return 0;
    return list.where((f) => f.wouldRecommend).length / list.length * 100;
  }
}
