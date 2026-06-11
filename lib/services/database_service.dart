import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../data/mock_data.dart';
import '../models/feedback.dart';
import '../models/message.dart';
import '../models/opportunity.dart';
import '../models/skill_listing.dart';

class DatabaseService {
  static Database? _db;
  bool _memoryInitialized = false;

  List<Opportunity> _memOpportunities = [];
  List<SkillListing> _memSkills = [];
  List<ChatMessage> _memMessages = [];
  List<EventFeedback> _memFeedback = [];

  bool get _useMemory => kIsWeb;

  void _initMemoryIfNeeded() {
    if (_memoryInitialized) return;
    _memOpportunities = List<Opportunity>.from(MockData.opportunities);
    _memSkills = List<SkillListing>.from(MockData.skillListings);
    _memFeedback = List<EventFeedback>.from(MockData.mockFeedback);
    _memMessages = [];
    for (final community in MockData.communities) {
      _memMessages.addAll(MockData.messagesForThread(community.id));
    }
    _memoryInitialized = true;
  }

  Future<Database> get database async {
    if (_useMemory) {
      throw UnsupportedError('SQLite is not available on web');
    }
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), 'alu_connect.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE opportunities (
        id TEXT PRIMARY KEY,
        title TEXT,
        category TEXT,
        description TEXT,
        organizer TEXT,
        date INTEGER,
        time TEXT,
        location TEXT,
        maxParticipants INTEGER,
        rsvpCount INTEGER,
        tags TEXT,
        requiredSkills TEXT,
        imageAsset TEXT,
        matchScore INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE messages (
        id TEXT PRIMARY KEY,
        threadId TEXT,
        senderId TEXT,
        senderName TEXT,
        content TEXT,
        timestamp INTEGER,
        isOwn INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE feedback (
        id TEXT PRIMARY KEY,
        eventId TEXT,
        userId TEXT,
        overallRating INTEGER,
        contentRating INTEGER,
        organizationRating INTEGER,
        networkingRating INTEGER,
        wouldRecommend INTEGER,
        comments TEXT,
        submittedAt INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE skills (
        id TEXT PRIMARY KEY,
        userId TEXT,
        userName TEXT,
        userCampus TEXT,
        skillTitle TEXT,
        category TEXT,
        description TEXT,
        mode TEXT,
        availability TEXT,
        maxSessionsPerWeek INTEGER,
        rating REAL,
        sessionCount INTEGER,
        requestCount INTEGER,
        isAvailable INTEGER,
        createdAt INTEGER
      )
    ''');

    final batch = db.batch();
    for (final opp in MockData.opportunities) {
      batch.insert('opportunities', opp.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    for (final community in MockData.communities) {
      for (final msg in MockData.messagesForThread(community.id)) {
        batch.insert('messages', msg.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace);
      }
    }
    for (final fb in MockData.mockFeedback) {
      batch.insert('feedback', fb.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    for (final skill in MockData.skillListings) {
      batch.insert('skills', skill.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  // ── Opportunities ────────────────────────────────────────────────────────
  Future<List<Opportunity>> getOpportunities() async {
    if (_useMemory) {
      _initMemoryIfNeeded();
      return List<Opportunity>.from(_memOpportunities)
        ..sort((a, b) => a.date.compareTo(b.date));
    }
    final db = await database;
    final rows = await db.query('opportunities', orderBy: 'date ASC');
    return rows.map(Opportunity.fromMap).toList();
  }

  Future<void> insertOpportunity(Opportunity opp) async {
    if (_useMemory) {
      _initMemoryIfNeeded();
      final idx = _memOpportunities.indexWhere((o) => o.id == opp.id);
      if (idx >= 0) {
        _memOpportunities[idx] = opp;
      } else {
        _memOpportunities.insert(0, opp);
      }
      return;
    }
    final db = await database;
    await db.insert('opportunities', opp.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateMatchScore(String id, int score) async {
    if (_useMemory) {
      _initMemoryIfNeeded();
      final idx = _memOpportunities.indexWhere((o) => o.id == id);
      if (idx >= 0) _memOpportunities[idx].matchScore = score;
      return;
    }
    final db = await database;
    await db
        .update('opportunities', {'matchScore': score}, where: 'id = ?', whereArgs: [id]);
  }

  // ── Messages ─────────────────────────────────────────────────────────────
  Future<List<ChatMessage>> getMessages(String threadId) async {
    if (_useMemory) {
      _initMemoryIfNeeded();
      return _memMessages
          .where((m) => m.threadId == threadId)
          .toList()
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    }
    final db = await database;
    final rows = await db.query('messages',
        where: 'threadId = ?',
        whereArgs: [threadId],
        orderBy: 'timestamp ASC');
    return rows.map(ChatMessage.fromMap).toList();
  }

  Future<void> insertMessage(ChatMessage message) async {
    if (_useMemory) {
      _initMemoryIfNeeded();
      final idx = _memMessages.indexWhere((m) => m.id == message.id);
      if (idx >= 0) {
        _memMessages[idx] = message;
      } else {
        _memMessages.add(message);
      }
      return;
    }
    final db = await database;
    await db.insert('messages', message.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // ── Feedback ─────────────────────────────────────────────────────────────
  Future<List<EventFeedback>> getFeedback(String eventId) async {
    if (_useMemory) {
      _initMemoryIfNeeded();
      return _memFeedback.where((f) => f.eventId == eventId).toList();
    }
    final db = await database;
    final rows = await db.query('feedback',
        where: 'eventId = ?', whereArgs: [eventId]);
    return rows.map(EventFeedback.fromMap).toList();
  }

  Future<bool> hasUserSubmittedFeedback(String eventId, String userId) async {
    if (_useMemory) {
      _initMemoryIfNeeded();
      return _memFeedback
          .any((f) => f.eventId == eventId && f.userId == userId);
    }
    final db = await database;
    final rows = await db.query('feedback',
        where: 'eventId = ? AND userId = ?', whereArgs: [eventId, userId]);
    return rows.isNotEmpty;
  }

  Future<void> insertFeedback(EventFeedback fb) async {
    if (_useMemory) {
      _initMemoryIfNeeded();
      final idx = _memFeedback.indexWhere((f) => f.id == fb.id);
      if (idx >= 0) {
        _memFeedback[idx] = fb;
      } else {
        _memFeedback.add(fb);
      }
      return;
    }
    final db = await database;
    await db.insert('feedback', fb.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // ── Skills ───────────────────────────────────────────────────────────────
  Future<List<SkillListing>> getSkills() async {
    if (_useMemory) {
      _initMemoryIfNeeded();
      return List<SkillListing>.from(_memSkills)
        ..sort((a, b) => b.rating.compareTo(a.rating));
    }
    final db = await database;
    final rows = await db.query('skills', orderBy: 'rating DESC');
    return rows.map(SkillListing.fromMap).toList();
  }

  Future<void> insertSkill(SkillListing skill) async {
    if (_useMemory) {
      _initMemoryIfNeeded();
      final idx = _memSkills.indexWhere((s) => s.id == skill.id);
      if (idx >= 0) {
        _memSkills[idx] = skill;
      } else {
        _memSkills.insert(0, skill);
      }
      return;
    }
    final db = await database;
    await db.insert('skills', skill.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateSkillAvailability(String id, bool isAvailable) async {
    if (_useMemory) {
      _initMemoryIfNeeded();
      final idx = _memSkills.indexWhere((s) => s.id == id);
      if (idx >= 0) _memSkills[idx].isAvailable = isAvailable;
      return;
    }
    final db = await database;
    await db.update('skills', {'isAvailable': isAvailable ? 1 : 0},
        where: 'id = ?', whereArgs: [id]);
  }
}
