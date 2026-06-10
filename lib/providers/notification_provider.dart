import 'package:flutter/material.dart';
import '../data/mock_data.dart';

class AppNotification {
  final String id;
  final String title;
  final String body;
  final DateTime time;
  bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    this.isRead = false,
  });
}

class NotificationProvider extends ChangeNotifier {
  final List<AppNotification> _notifications = MockData.notifications
      .map((m) => AppNotification(
            id: m['id'] as String,
            title: m['title'] as String,
            body: m['body'] as String,
            time: m['time'] as DateTime,
            isRead: m['isRead'] as bool,
          ))
      .toList();

  List<AppNotification> get all => List.unmodifiable(_notifications);

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  void addNotification({required String title, required String body}) {
    _notifications.insert(
      0,
      AppNotification(
        id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        body: body,
        time: DateTime.now(),
        isRead: false,
      ),
    );
    notifyListeners();
  }

  void markAllRead() {
    for (final n in _notifications) {
      n.isRead = true;
    }
    notifyListeners();
  }

  void markRead(String id) {
    final n = _notifications.where((n) => n.id == id).firstOrNull;
    if (n != null) {
      n.isRead = true;
      notifyListeners();
    }
  }
}
