import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../constants/colors.dart';
import '../../constants/text_styles.dart';
import '../../providers/campus_pulse_provider.dart';
import '../../widgets/rsvp_button.dart';

class CampusPulseScreen extends StatelessWidget {
  const CampusPulseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Campus Pulse 🔥', style: AppTextStyles.headlineLarge),
            Text(
              'What\'s happening at ALU right now',
              style: AppTextStyles.bodySmall,
            ),
          ],
        ),
      ),
      body: Consumer<CampusPulseProvider>(
        builder: (context, pulse, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section 1: Most Active Clubs
                _SectionHeader(title: 'Most Active Clubs'),
                const SizedBox(height: 12),
                SizedBox(
                  height: 160,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: pulse.clubActivity.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, i) {
                      final club = pulse.clubActivity[i];
                      final isTop = i == 0;
                      final activityPercent =
                          (club['activityScore'] as int) / 100.0;
                      return Container(
                        width: 140,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  club['emoji'] as String,
                                  style: const TextStyle(fontSize: 26),
                                ),
                                if (isTop) ...[
                                  const Spacer(),
                                  const Text('🔥',
                                      style: TextStyle(fontSize: 14)),
                                ],
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              club['name'] as String,
                              style: AppTextStyles.titleMedium
                                  .copyWith(fontSize: 12),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${club['postCount']} posts this week',
                              style: AppTextStyles.bodySmall
                                  .copyWith(fontSize: 10),
                            ),
                            const SizedBox(height: 8),
                            LinearPercentIndicator(
                              lineHeight: 6,
                              percent: activityPercent,
                              progressColor: AppColors.primary,
                              backgroundColor: AppColors.surface,
                              barRadius: const Radius.circular(3),
                              padding: EdgeInsets.zero,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // Section 2: Trending Events
                _SectionHeader(title: 'Trending Events 📈'),
                const SizedBox(height: 12),
                ...pulse.trendingEvents.map((event) {
                  final rsvp = event['rsvpCount'] as int;
                  final capacity = event['capacity'] as int;
                  final ratio = capacity > 0 ? rsvp / capacity : 0.0;
                  final isFillingUp = ratio >= 0.8;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: isFillingUp
                          ? Border.all(
                              color: AppColors.error.withOpacity(0.4),
                              width: 1.5)
                          : null,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                event['title'] as String,
                                style: AppTextStyles.titleMedium,
                              ),
                            ),
                            if (isFillingUp)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.error.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Filling up fast! 🔴',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: AppColors.error,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearPercentIndicator(
                          lineHeight: 8,
                          percent: ratio.clamp(0.0, 1.0),
                          progressColor: isFillingUp
                              ? AppColors.error
                              : AppColors.primary,
                          backgroundColor: AppColors.surface,
                          barRadius: const Radius.circular(4),
                          padding: EdgeInsets.zero,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '$rsvp / $capacity spots filled',
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 20),

                // Section 3: Most Discussed
                _SectionHeader(title: 'Most Discussed 🗣'),
                const SizedBox(height: 12),
                ...pulse.discussedOpportunities.map((opp) {
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 4),
                    tileColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    title: Text(
                      opp['title'] as String,
                      style: AppTextStyles.titleMedium,
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '🗣 ${opp['commentCount']} talking',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  );
                }).toList().expand((w) => [w, const SizedBox(height: 6)]).toList(),
                const SizedBox(height: 20),

                // Section 4: Events Filling Up
                _SectionHeader(title: 'Events Filling Up ⚡'),
                const SizedBox(height: 12),
                ...pulse.fillingUpEvents.map((event) {
                  final rsvp = event['rsvpCount'] as int;
                  final capacity = event['capacity'] as int;
                  final spotsLeft = capacity - rsvp;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppColors.error.withOpacity(0.35),
                          width: 1.5),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                event['title'] as String,
                                style: AppTextStyles.titleMedium,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Only $spotsLeft spots left!',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.error,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        RsvpButton(
                          eventId: event['id'] as String,
                          eventName: event['title'] as String,
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 20),

                // Section 5: Campus Mood
                _SectionHeader(title: 'Campus Mood 💭'),
                const SizedBox(height: 6),
                Text(
                  "How's the vibe today?",
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.subtleText),
                ),
                const SizedBox(height: 12),
                _MoodSection(pulse: pulse),
                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(title, style: AppTextStyles.headlineSmall);
  }
}

class _MoodSection extends StatelessWidget {
  final CampusPulseProvider pulse;

  const _MoodSection({required this.pulse});

  static const _moods = [
    {'key': 'fire', 'emoji': '🔥', 'label': 'Hyped'},
    {'key': 'happy', 'emoji': '😊', 'label': 'Good'},
    {'key': 'neutral', 'emoji': '😐', 'label': 'Neutral'},
    {'key': 'chill', 'emoji': '😴', 'label': 'Chill'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          if (!pulse.hasVotedToday) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _moods.map((mood) {
                return GestureDetector(
                  onTap: () => pulse.vote(mood['key']!),
                  child: Column(
                    children: [
                      Text(
                        mood['emoji']!,
                        style: const TextStyle(fontSize: 36),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        mood['label']!,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.darkText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ] else ...[
            Row(
              children: [
                Icon(Icons.check_circle,
                    color: const Color(0xFF4CAF50), size: 16),
                const SizedBox(width: 6),
                Text(
                  'Voted today ✓',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: const Color(0xFF4CAF50),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ..._moods.map((mood) {
              final percent = pulse.moodPercent(mood['key']!);
              final isVoted = pulse.userVote == mood['key'];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Text(mood['emoji']!,
                        style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 60,
                      child: Text(
                        mood['label']!,
                        style: AppTextStyles.bodySmall.copyWith(
                          fontWeight: isVoted
                              ? FontWeight.w700
                              : FontWeight.w400,
                          color: isVoted
                              ? AppColors.primary
                              : AppColors.darkText,
                        ),
                      ),
                    ),
                    Expanded(
                      child: LinearPercentIndicator(
                        lineHeight: 10,
                        percent: percent.clamp(0.0, 1.0),
                        progressColor: isVoted
                            ? AppColors.primary
                            : AppColors.subtleText,
                        backgroundColor: AppColors.surface,
                        barRadius: const Radius.circular(5),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${(percent * 100).round()}%',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}
