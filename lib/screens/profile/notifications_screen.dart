import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../constants/text_styles.dart';
import '../../providers/notification_provider.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<NotificationProvider>();
    final notes = prov.all;
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications', style: AppTextStyles.headlineSmall),
        actions: [
          TextButton(onPressed: prov.markAllRead, child: const Text('Mark all'))
        ],
      ),
      backgroundColor: AppColors.surface,
      body: ListView.separated(
        itemCount: notes.length,
        separatorBuilder: (_, __) => const Divider(height: 0.5, indent: 16),
        itemBuilder: (context, i) {
          final n = notes[i];
          return ListTile(
            leading: Icon(Icons.notifications_outlined, color: n.isRead ? AppColors.subtleText : AppColors.primary),
            title: Text(n.title, style: AppTextStyles.titleMedium.copyWith(fontWeight: n.isRead ? FontWeight.w500 : FontWeight.w700)),
            subtitle: Text(n.body, style: AppTextStyles.bodySmall),
            trailing: n.isRead ? null : const Icon(Icons.circle, size: 10, color: AppColors.primary),
            onTap: () => prov.markRead(n.id),
          );
        },
      ),
    );
  }
}
