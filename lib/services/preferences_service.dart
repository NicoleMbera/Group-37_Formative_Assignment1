import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const _keyOnboardingDone = 'onboarding_done';
  static const _keyInterests = 'interests';
  static const _keyPathway = 'pathway';
  static const _keySkills = 'skills';
  static const _keyUser = 'user';
  static const _keyRegisteredUsers = 'registered_users';
  static const _keyRsvps = 'rsvps';
  static const _keyMoodDate = 'mood_date';
  static const _keyMoodVote = 'mood_vote';

  final SharedPreferences _prefs;

  PreferencesService(this._prefs);

  static Future<PreferencesService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return PreferencesService(prefs);
  }

  // Onboarding
  bool get isOnboardingDone => _prefs.getBool(_keyOnboardingDone) ?? false;
  Future<void> setOnboardingDone() => _prefs.setBool(_keyOnboardingDone, true);

  // Interests / pathway / skills
  List<String> get interests =>
      _prefs.getStringList(_keyInterests) ?? [];
  Future<void> setInterests(List<String> v) =>
      _prefs.setStringList(_keyInterests, v);

  String get pathway => _prefs.getString(_keyPathway) ?? '';
  Future<void> setPathway(String v) => _prefs.setString(_keyPathway, v);

  List<String> get skills => _prefs.getStringList(_keySkills) ?? [];
  Future<void> setSkills(List<String> v) => _prefs.setStringList(_keySkills, v);

  // User JSON
  String? get userJson => _prefs.getString(_keyUser);
  Future<void> setUserJson(String json) => _prefs.setString(_keyUser, json);
  Future<void> clearUser() => _prefs.remove(_keyUser);

  // Registered users (email -> userJson)
  Map<String, String> get registeredUsers {
    final raw = _prefs.getString(_keyRegisteredUsers);
    if (raw == null) return {};
    return Map<String, String>.from(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> addRegisteredUser(String email, String userJson) async {
    final map = registeredUsers;
    map[email.trim().toLowerCase()] = userJson;
    await _prefs.setString(_keyRegisteredUsers, jsonEncode(map));
  }

  bool isRegisteredEmail(String email) => registeredUsers.containsKey(email.trim().toLowerCase());

  String? registeredUserJson(String email) => registeredUsers[email.trim().toLowerCase()];

  // RSVPs: {"eventId": "going"|"interested"}
  Map<String, String> get rsvps {
    final raw = _prefs.getString(_keyRsvps);
    if (raw == null) return {};
    return Map<String, String>.from(jsonDecode(raw) as Map);
  }

  Future<void> saveRsvps(Map<String, String> rsvps) =>
      _prefs.setString(_keyRsvps, jsonEncode(rsvps));

  // Campus mood (once per day)
  bool get hasVotedToday {
    final saved = _prefs.getString(_keyMoodDate);
    if (saved == null) return false;
    final savedDate = DateTime.parse(saved);
    final now = DateTime.now();
    return savedDate.year == now.year &&
        savedDate.month == now.month &&
        savedDate.day == now.day;
  }

  String? get todayMoodVote => _prefs.getString(_keyMoodVote);

  Future<void> saveMoodVote(String mood) async {
    await _prefs.setString(_keyMoodDate, DateTime.now().toIso8601String());
    await _prefs.setString(_keyMoodVote, mood);
  }

  Future<void> clearAll() => _prefs.clear();
}
