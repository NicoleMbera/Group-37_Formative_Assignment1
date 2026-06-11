import 'package:flutter/material.dart';

import '../models/skill_listing.dart';
import '../services/database_service.dart';

class SkillProvider extends ChangeNotifier {
  final DatabaseService _db;
  List<SkillListing> _all = [];
  String _filter = 'All';
  String _search = '';
  bool _isLoading = false;

  SkillProvider(this._db);

  List<SkillListing> get all => _all;
  bool get isLoading => _isLoading;

  List<SkillListing> get filtered {
    var list = _filter == 'All'
        ? _all
        : _all.where((s) => s.category == _filter).toList();
    if (_search.isNotEmpty) {
      final q = _search.toLowerCase();
      list = list
          .where((s) =>
              s.skillTitle.toLowerCase().contains(q) ||
              s.userName.toLowerCase().contains(q) ||
              s.description.toLowerCase().contains(q))
          .toList();
    }
    return list;
  }

  List<SkillListing> myListings(String userId) =>
      _all.where((s) => s.userId == userId).toList();

  Future<void> loadSkills() async {
    _isLoading = true;
    notifyListeners();
    try {
      _all = await _db.getSkills();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addSkill(SkillListing skill) async {
    await _db.insertSkill(skill);
    _all.insert(0, skill);
    notifyListeners();
  }

  Future<void> toggleAvailability(String id) async {
    final idx = _all.indexWhere((s) => s.id == id);
    if (idx == -1) return;
    _all[idx].isAvailable = !_all[idx].isAvailable;
    await _db.updateSkillAvailability(id, _all[idx].isAvailable);
    notifyListeners();
  }

  void setFilter(String f) {
    _filter = f;
    notifyListeners();
  }

  void setSearch(String q) {
    _search = q;
    notifyListeners();
  }

  SkillListing? findById(String id) {
    try {
      return _all.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }
}
