import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../constants/colors.dart';
import '../../constants/text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../providers/feed_provider.dart';
import '../../providers/feedback_provider.dart';
import '../../widgets/analytics_chart.dart';
import '../../widgets/pulse_stat_card.dart';

class FeedbackAnalyticsScreen extends StatefulWidget {
  final String eventId;

  const FeedbackAnalyticsScreen({super.key, required this.eventId});

  @override
  State<FeedbackAnalyticsScreen> createState() =>
      _FeedbackAnalyticsScreenState();
}

class _FeedbackAnalyticsScreenState
    extends State<FeedbackAnalyticsScreen> {
  String _eventName = '';
  bool _loaded = false;
  bool _initialized = false;

  String get _eventId => widget.eventId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      final opp = context.read<FeedProvider>().findById(_eventId);
      _eventName = opp?.title ?? 'Event';
      context.read<FeedbackProvider>().loadFeedback(_eventId).then((_) {
        if (mounted) setState(() => _loaded = true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final isOrganizer = user?.isOrganizer ?? false;

    if (!isOrganizer) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          title:
              Text('Access Denied', style: AppTextStyles.headlineSmall),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_outline,
                    size: 64, color: AppColors.subtleText),
                const SizedBox(height: 16),
                Text(
                  'Analytics are only available to event organizers and staff.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.subtleText),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          '$_eventName — Feedback Report',
          style: AppTextStyles.headlineSmall,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Export coming soon!'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: const Icon(Icons.picture_as_pdf_outlined,
                color: AppColors.primary),
            label: Text(
              'Export PDF',
              style: GoogleFonts.poppins(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
      body: !_loaded
          ? const Center(
              child:
                  CircularProgressIndicator(color: AppColors.primary))
          : Consumer<FeedbackProvider>(
              builder: (context, feedbackProvider, _) {
                final eventId = _eventId;
                final feedbackList =
                    feedbackProvider.feedbackFor(eventId);
                final avgOverall =
                    feedbackProvider.averageOverall(eventId);
                final distribution =
                    feedbackProvider.ratingDistribution(eventId);
                final categoryAvgs =
                    feedbackProvider.categoryAverages(eventId);
                final recommendRate =
                    feedbackProvider.recommendationRate(eventId);

                final opp =
                    context.read<FeedProvider>().findById(eventId);
                final attendanceRate = opp != null &&
                        opp.maxParticipants > 0
                    ? feedbackList.length / opp.maxParticipants * 100
                    : 0.0;

                final recentComments = feedbackList
                    .where((f) => f.comments.isNotEmpty)
                    .toList()
                    .reversed
                    .take(5)
                    .toList();

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Summary cards
                      Row(
                        children: [
                          Expanded(
                            child: PulseStatCard(
                              emoji: '⭐',
                              title: 'Avg Rating',
                              value: avgOverall.toStringAsFixed(1),
                              subtitle: 'out of 5 stars',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: PulseStatCard(
                              emoji: '📝',
                              title: 'Responses',
                              value: feedbackList.length.toString(),
                              subtitle: 'total submissions',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: PulseStatCard(
                              emoji: '📊',
                              title: 'Attendance',
                              value:
                                  '${attendanceRate.round()}%',
                              subtitle: 'responded',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Rating distribution
                      Text(
                        'Rating Distribution',
                        style: AppTextStyles.headlineSmall,
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: AnalyticsChart(distribution: distribution),
                      ),
                      const SizedBox(height: 20),

                      // Category averages
                      Text(
                        'Category Averages',
                        style: AppTextStyles.headlineSmall,
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: feedbackList.isEmpty
                            ? Center(
                                child: Text(
                                  'No feedback yet',
                                  style: AppTextStyles.bodySmall,
                                ),
                              )
                            : Column(
                                children: [
                                  'Overall',
                                  'Content',
                                  'Organization',
                                  'Networking',
                                ].map((cat) {
                                  final avg =
                                      (categoryAvgs[cat] ?? 0) / 5;
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 6),
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 100,
                                          child: Text(
                                            cat,
                                            style:
                                                AppTextStyles.bodySmall,
                                          ),
                                        ),
                                        Expanded(
                                          child: LinearPercentIndicator(
                                            lineHeight: 10,
                                            percent: avg.clamp(0.0, 1.0),
                                            progressColor:
                                                AppColors.primary,
                                            backgroundColor:
                                                AppColors.surface,
                                            barRadius:
                                                const Radius.circular(5),
                                            padding: EdgeInsets.zero,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          (avg * 5).toStringAsFixed(1),
                                          style: AppTextStyles.bodySmall
                                              .copyWith(
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.darkText,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                      ),
                      const SizedBox(height: 20),

                      // Recommendation rate
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Text('👍',
                                style: TextStyle(fontSize: 28)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Recommendation Rate',
                                    style: AppTextStyles.labelMedium,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${recommendRate.round()}% would recommend this event',
                                    style: AppTextStyles.titleMedium,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Recent comments
                      if (recentComments.isNotEmpty) ...[
                        Text(
                          'Recent Comments',
                          style: AppTextStyles.headlineSmall,
                        ),
                        const SizedBox(height: 12),
                        ...recentComments.map(
                          (fb) => Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: const Border(
                                left: BorderSide(
                                  color: AppColors.primary,
                                  width: 3,
                                ),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: List.generate(
                                    fb.overallRating,
                                    (_) => const Icon(
                                      Icons.star_rounded,
                                      size: 14,
                                      color: AppColors.accent,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  fb.comments,
                                  style: AppTextStyles.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 32),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
