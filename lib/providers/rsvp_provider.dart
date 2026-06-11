import 'package:flutter/material.dart';

import '../models/rsvp.dart';
import '../services/preferences_service.dart';

class RsvpProvider extends ChangeNotifier {
  final PreferencesService _prefs;
  Map<String, RsvpStatus> _rsvps = {};

  RsvpProvider(this._prefs) {
    _load();
  }

  Map<String, RsvpStatus> get rsvps => Map.unmodifiable(_rsvps);

  RsvpStatus statusFor(String eventId) =>
      _rsvps[eventId] ?? RsvpStatus.none;

  bool isGoing(String eventId) => statusFor(eventId) == RsvpStatus.going;
  bool isInterested(String eventId) => statusFor(eventId) == RsvpStatus.interested;

  List<String> get goingEventIds =>
      _rsvps.entries.where((e) => e.value == RsvpStatus.going).map((e) => e.key).toList();

  void _load() {
    final raw = _prefs.rsvps;
    _rsvps = raw.map((k, v) => MapEntry(k, _fromString(v)));
  }

  Future<void> toggleGoing(String eventId) async {
    if (_rsvps[eventId] == RsvpStatus.going) {
      _rsvps.remove(eventId);
    } else {
      _rsvps[eventId] = RsvpStatus.going;
    }
    await _persist();
    notifyListeners();
  }

  Future<void> toggleInterested(String eventId) async {
    if (_rsvps[eventId] == RsvpStatus.interested) {
      _rsvps.remove(eventId);
    } else {
      _rsvps[eventId] = RsvpStatus.interested;
    }
    await _persist();
    notifyListeners();
  }

  Future<void> _persist() async {
    final raw = _rsvps.map((k, v) => MapEntry(k, _toString(v)));
    await _prefs.saveRsvps(raw);
  }

  RsvpStatus _fromString(String s) {
    switch (s) {
      case 'going':
        return RsvpStatus.going;
      case 'interested':
        return RsvpStatus.interested;
      default:
        return RsvpStatus.none;
    }
  }

  String _toString(RsvpStatus s) {
    switch (s) {
      case RsvpStatus.going:
        return 'going';
      case RsvpStatus.interested:
        return 'interested';
      case RsvpStatus.none:
        return 'none';
    }
  }
}
