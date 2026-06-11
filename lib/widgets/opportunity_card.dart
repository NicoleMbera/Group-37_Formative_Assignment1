import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';
import '../models/opportunity.dart';
import 'category_chip.dart';
import 'match_score_badge.dart';
import 'rsvp_button.dart';

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

class OpportunityCard extends StatelessWidget {
  final Opportunity opportunity;
  final VoidCallback? onTap;

  const OpportunityCard({
    super.key,
    required this.opportunity,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final catColor = AppColors.categoryColor(opportunity.category);

    return GestureDetector(
      onTap: onTap ??
          () => Navigator.pushNamed(
                context,
                '/opportunity-detail',
                arguments: opportunity.id,
              ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border(
            left: BorderSide(color: catColor, width: 4),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Hero(
                    tag: 'opp_icon_${opportunity.id}',
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: catColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _categoryIcon(opportunity.category),
                        color: catColor,
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CategoryChip(category: opportunity.category),
                        const SizedBox(height: 4),
                        Text(
                          opportunity.title,
                          style: AppTextStyles.headlineSmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (opportunity.matchScore > 0)
                    MatchScoreBadge(
                      score: opportunity.matchScore,
                      size: 50,
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.calendar_today_outlined,
                      size: 13, color: AppColors.subtleText),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('MMM d, yyyy').format(opportunity.date),
                    style: AppTextStyles.bodySmall,
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.location_on_outlined,
                      size: 13, color: AppColors.subtleText),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      opportunity.location,
                      style: AppTextStyles.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.person_outline,
                      size: 13, color: AppColors.subtleText),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      opportunity.organizer,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  RsvpButton(
                    eventId: opportunity.id,
                    eventName: opportunity.title,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
