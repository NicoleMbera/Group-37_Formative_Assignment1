import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../services/preferences_service.dart';

class CampusPulseProvider extends ChangeNotifier {
  final PreferencesService _prefs;

  // Mood votes — starts from mock data, augmented by user vote
  Map<String, int> _moodVotes = Map.from(MockData.campusMoodVotes);
  String? _userVote;

  CampusPulseProvider(this._prefs) {
    _userVote = _prefs.hasVotedToday ? _prefs.todayMoodVote : null;
    if (_userVote != null && _moodVotes.containsKey(_userVote)) {
      // Don't double count — vote is already in mock totals
    }
  }

  Map<String, int> get moodVotes => Map.unmodifiable(_moodVotes);
  String? get userVote => _userVote;
  bool get hasVotedToday => _prefs.hasVotedToday;
  int get totalVotes => _moodVotes.values.fold(0, (a, b) => a + b);

  List<Map<String, dynamic>> get clubActivity => MockData.clubActivity;
  List<Map<String, dynamic>> get trendingEvents => MockData.trendingEvents;
  List<Map<String, dynamic>> get discussedOpportunities =>
      MockData.discussedOpportunities;
  List<Map<String, dynamic>> get fillingUpEvents => MockData.fillingUpEvents;

  Future<void> vote(String mood) async {
    if (hasVotedToday) return;
    _moodVotes[mood] = (_moodVotes[mood] ?? 0) + 1;
    _userVote = mood;
    await _prefs.saveMoodVote(mood);
    notifyListeners();
  }

  double moodPercent(String mood) {
    final total = totalVotes;
    if (total == 0) return 0;
    return (_moodVotes[mood] ?? 0) / total;
  }
}
