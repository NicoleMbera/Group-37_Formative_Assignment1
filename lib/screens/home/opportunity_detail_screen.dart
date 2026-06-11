import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../constants/colors.dart';
import '../../constants/text_styles.dart';
import '../../models/opportunity.dart';
import '../../providers/auth_provider.dart';
import '../../providers/feed_provider.dart';
import '../../providers/rsvp_provider.dart';
import '../../widgets/rsvp_button.dart';

IconData _categoryIcon(String category) {
  switch (category.toLowerCase()) {
    case 'hackathons':
    case 'hackathon':
      return Icons.code;
    case 'events':
    case 'event':
      return Icons.event;
    case 'workshops':
    case 'workshop':
      return Icons.school;
    case 'internships':
    case 'internship':
      return Icons.work;
    default:
      return Icons.star;
  }
}

class OpportunityDetailScreen extends StatelessWidget {
  final String id;

  const OpportunityDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    final opp = context.watch<FeedProvider>().findById(id);

    if (opp == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Opportunity not found')),
      );
    }

    return _OpportunityDetailBody(opportunity: opp);
  }
}

class _OpportunityDetailBody extends StatelessWidget {
  final Opportunity opportunity;

  const _OpportunityDetailBody({required this.opportunity});

  String _countdown() {
    final now = DateTime.now();
    final diff = opportunity.date.difference(now);
    if (diff.isNegative) return 'Past event';
    if (diff.inDays > 0) return 'In ${diff.inDays} days';
    if (diff.inHours > 0) return 'In ${diff.inHours} hours';
    return 'Today!';
  }

  @override
  Widget build(BuildContext context) {
    final catColor = AppColors.categoryColor(opportunity.category);
    final user = context.watch<AuthProvider>().user;
    final rsvpProvider = context.watch<RsvpProvider>();
    final isGoing = rsvpProvider.isGoing(opportunity.id);
    final matchedTags = user != null
        ? opportunity.tags
            .where((t) =>
                user.interests.any((i) => i.toLowerCase() == t.toLowerCase()))
            .toList()
        : <String>[];

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: catColor,
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'opp_icon_${opportunity.id}',
                child: Container(
                  color: catColor,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        Icon(
                          _categoryIcon(opportunity.category),
                          size: 80,
                          color: AppColors.white.withOpacity(0.9),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            opportunity.category,
                            style: GoogleFonts.poppins(
                              color: AppColors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(opportunity.title, style: AppTextStyles.displayMedium),
                  const SizedBox(height: 6),
                  if (!opportunity.isPast)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _countdown(),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),

                  // Match Score Section
                  if (opportunity.matchScore > 0) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          TweenAnimationBuilder<double>(
                            tween: Tween<double>(
                                begin: 0,
                                end: opportunity.matchScore / 100.0),
                            duration: const Duration(milliseconds: 1200),
                            curve: Curves.easeOut,
                            builder: (_, value, __) {
                              final displayScore =
                                  (value * opportunity.matchScore).round();
                              final color = AppColors.matchColor(displayScore);
                              return CircularPercentIndicator(
                                radius: 50,
                                lineWidth: 8,
                                percent: value,
                                center: Text(
                                  '$displayScore%',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: color,
                                  ),
                                ),
                                progressColor: color,
                                backgroundColor: color.withOpacity(0.15),
                                circularStrokeCap: CircularStrokeCap.round,
                              );
                            },
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${opportunity.matchScore}% match with your profile',
                                  style: AppTextStyles.titleMedium,
                                ),
                                const SizedBox(height: 8),
                                if (matchedTags.isNotEmpty) ...[
                                  Text(
                                    'Matched on:',
                                    style: AppTextStyles.bodySmall,
                                  ),
                                  const SizedBox(height: 4),
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 4,
                                    children: matchedTags
                                        .map((tag) => Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 3),
                                              decoration: BoxDecoration(
                                                color: AppColors.primary
                                                    .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                tag,
                                                style: AppTextStyles
                                                    .labelSmall
                                                    .copyWith(
                                                  color: AppColors.primary,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ))
                                        .toList(),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Details card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _InfoRow(
                          icon: Icons.person_outline,
                          label: 'Organizer',
                          value: opportunity.organizer,
                        ),
                        const Divider(height: 20),
                        _InfoRow(
                          icon: Icons.calendar_today_outlined,
                          label: 'Date',
                          value:
                              '${DateFormat('EEEE, MMM d, yyyy').format(opportunity.date)} · ${opportunity.time}',
                        ),
                        const Divider(height: 20),
                        _InfoRow(
                          icon: Icons.location_on_outlined,
                          label: 'Location',
                          value: opportunity.location,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Description
                  Text('About', style: AppTextStyles.headlineSmall),
                  const SizedBox(height: 8),
                  Text(
                    opportunity.description,
                    style: AppTextStyles.bodyMedium.copyWith(height: 1.6),
                  ),
                  const SizedBox(height: 20),

                  // Tags
                  if (opportunity.tags.isNotEmpty) ...[
                    Text('Tags', style: AppTextStyles.headlineSmall),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: opportunity.tags
                          .map((tag) => Chip(
                                label: Text(tag,
                                    style: AppTextStyles.labelMedium
                                        .copyWith(
                                            color: AppColors.darkText)),
                                backgroundColor: AppColors.surface,
                                side: const BorderSide(
                                    color: Color(0xFFDDDDDD)),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 4),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Attendees
                  Text('Attendees', style: AppTextStyles.headlineSmall),
                  const SizedBox(height: 8),
                  _AttendeesRow(opportunity: opportunity),
                  const SizedBox(height: 24),

                  // Action buttons
                  if (!opportunity.isPast) ...[
                    Row(
                      children: [
                        Expanded(
                          child: RsvpButton(
                            eventId: opportunity.id,
                            eventName: opportunity.title,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              context
                                  .read<RsvpProvider>()
                                  .toggleInterested(opportunity.id);
                            },
                            icon: Icon(
                              rsvpProvider.isInterested(opportunity.id)
                                  ? Icons.bookmark
                                  : Icons.bookmark_border,
                              size: 18,
                            ),
                            label: Text(
                              rsvpProvider.isInterested(opportunity.id)
                                  ? 'Saved'
                                  : 'Interested',
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side:
                                  const BorderSide(color: AppColors.primary),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ] else if (isGoing) ...[
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.pushNamed(
                          context,
                          '/feedback-form',
                          arguments: opportunity.id,
                        ),
                        icon: const Icon(Icons.rate_review_outlined,
                            size: 18),
                        label: const Text('Rate this event'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.subtleText),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: AppTextStyles.labelMedium
                      .copyWith(color: AppColors.subtleText)),
              const SizedBox(height: 2),
              Text(value, style: AppTextStyles.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}

class _AttendeesRow extends StatelessWidget {
  final Opportunity opportunity;

  const _AttendeesRow({required this.opportunity});

  @override
  Widget build(BuildContext context) {
    final count = opportunity.rsvpCount.clamp(0, opportunity.maxParticipants);
    final avatarCount = count.clamp(0, 5);
    final initials = ['AK', 'BM', 'CF', 'DL', 'EO'];

    return Row(
      children: [
        SizedBox(
          width: (avatarCount * 22.0) + 8,
          height: 28,
          child: Stack(
            children: List.generate(avatarCount, (i) {
              return Positioned(
                left: i * 22.0,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1 + i * 0.1),
                    shape: BoxShape.circle,
                    border:
                        Border.all(color: AppColors.white, width: 1.5),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    initials[i % initials.length],
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.primary,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          '$count / ${opportunity.maxParticipants} attendees',
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        if (opportunity.isFillingUp) ...[
          const SizedBox(width: 6),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Filling up!',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
