import 'dart:convert';
import 'package:flutter/material.dart';

import '../models/user.dart';
import '../services/preferences_service.dart';

class AuthProvider extends ChangeNotifier {
  AppUser? _user;
  final PreferencesService _prefs;

  AuthProvider(this._prefs) {
    _loadUser();
  }

  AppUser? get user => _user;
  bool get isLoggedIn => _user != null;

  void _loadUser() {
    final json = _prefs.userJson;
    if (json != null) {
      _user = AppUser.fromMap(jsonDecode(json) as Map<String, dynamic>);
    }
  }

  // ── Preset mock accounts (email → {name, role, campus}) ──────────────────
  static const Map<String, Map<String, String>> _mockAccounts = {
    // Event Organizers
    'organizer@alu.edu':   {'name': 'Fatima Al-Hassan',   'role': 'Event Organizer', 'campus': 'Kigali'},
    'fatima@alu.edu':      {'name': 'Fatima Al-Hassan',   'role': 'Event Organizer', 'campus': 'Kigali'},
    // Club Leaders
    'clubleader@alu.edu':  {'name': 'Kwame Mensah',       'role': 'Club Leader',     'campus': 'Kigali'},
    'kwame@alu.edu':       {'name': 'Kwame Mensah',       'role': 'Club Leader',     'campus': 'Kigali'},
    // Academic Staff
    'staff@alu.edu':       {'name': 'Dr. Nkosi Dlamini',  'role': 'Academic Staff',  'campus': 'Mauritius'},
    'nkosi@alu.edu':       {'name': 'Dr. Nkosi Dlamini',  'role': 'Academic Staff',  'campus': 'Mauritius'},
    // Entrepreneur
    'entrepreneur@alu.edu': {'name': 'Tunde Adeyemi',     'role': 'Entrepreneur',    'campus': 'Kigali'},
    // Default student
    'aline@alustudent.com': {'name': 'Aline Umuhoza',     'role': 'Student',         'campus': 'Kigali'},
  };

  Future<void> login(String email, String password) async {
    final key = email.trim().toLowerCase();

    // Allow login only for preset mock accounts or previously registered users
    final preset = _mockAccounts[key];
    if (preset == null && !_prefs.isRegisteredEmail(email)) {
      throw Exception('No account found for this email. Please register first.');
    }

    String name;
    String role;
    String campus;

    if (preset != null) {
      name = preset['name']!;
      role = preset['role']!;
      campus = preset['campus']!;
    } else {
      // Load registered user JSON
      final json = _prefs.registeredUserJson(email)!;
      final map = jsonDecode(json) as Map<String, dynamic>;
      final regUser = AppUser.fromMap(map);
      name = regUser.fullName;
      role = regUser.role;
      campus = regUser.campus;
    }

    final user = AppUser(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      fullName: name,
      email: email.trim(),
      campus: campus,
      role: role,
      interests: _prefs.interests,
      pathway: _prefs.pathway,
      skills: _prefs.skills,
    );
    await _persistUser(user);
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String campus,
    required String role,
  }) async {
    final user = AppUser(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      fullName: fullName,
      email: email,
      campus: campus,
      role: role,
      interests: _prefs.interests,
      pathway: _prefs.pathway,
      skills: _prefs.skills,
    );
    // Save as a registered account so login requires registration
    await _prefs.addRegisteredUser(email, jsonEncode(user.toMap()));
    await _persistUser(user);
  }

  Future<void> _persistUser(AppUser user) async {
    _user = user;
    await _prefs.setUserJson(jsonEncode(user.toMap()));
    notifyListeners();
  }

  Future<void> updateUser(AppUser user) async {
    await _persistUser(user);
  }

  Future<void> logout() async {
    _user = null;
    await _prefs.clearUser();
    notifyListeners();
  }

  String _capitalize(String s) => s
      .split(' ')
      .map((w) => w.isEmpty ? '' : w[0].toUpperCase() + w.substring(1))
      .join(' ');
}
