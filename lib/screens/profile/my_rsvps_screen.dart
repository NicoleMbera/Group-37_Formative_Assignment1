import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../constants/colors.dart';
import '../../constants/text_styles.dart';
import '../../providers/feed_provider.dart';
import '../../providers/rsvp_provider.dart';

class MyRsvpsScreen extends StatelessWidget {
  const MyRsvpsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text('My RSVPs', style: AppTextStyles.headlineSmall),
      ),
      body: Consumer2<RsvpProvider, FeedProvider>(
        builder: (context, rsvpProvider, feedProvider, _) {
          final goingIds = rsvpProvider.goingEventIds;

          if (goingIds.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.event_available_outlined,
                        size: 64, color: AppColors.subtleText),
                    const SizedBox(height: 16),
                    Text(
                      'No RSVPs yet',
                      style: AppTextStyles.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Events you RSVP to will appear here.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.subtleText,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final events = goingIds
              .map((id) => feedProvider.findById(id))
              .where((o) => o != null)
              .toList();

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: events.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final opp = events[i]!;
              final isPast = opp.isPast;
              final catColor = AppColors.categoryColor(opp.category);

              return Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border(
                    left: BorderSide(color: catColor, width: 4),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              opp.title,
                              style: AppTextStyles.titleMedium,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.calendar_today_outlined,
                                    size: 12,
                                    color: AppColors.subtleText),
                                const SizedBox(width: 4),
                                Text(
                                  DateFormat('MMM d, yyyy')
                                      .format(opp.date),
                                  style: AppTextStyles.bodySmall,
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4CAF50)
                                    .withOpacity(0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Going ✓',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: const Color(0xFF4CAF50),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isPast) ...[
                        const SizedBox(width: 10),
                        OutlinedButton(
                          onPressed: () => Navigator.pushNamed(
                            context,
                            '/feedback-form',
                            arguments: opp.id,
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(
                                color: AppColors.primary),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            'Feedback',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
