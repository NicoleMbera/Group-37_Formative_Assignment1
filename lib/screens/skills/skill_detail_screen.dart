import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/colors.dart';
import '../../constants/text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/skill_provider.dart';
import '../../widgets/user_avatar.dart';
import '../../widgets/star_rating_bar.dart';

const _mockReviews = [
  {
    'name': 'Amara Diallo',
    'rating': 5,
    'text': 'Super helpful session! Learned so much in just one hour.',
  },
  {
    'name': 'Kevin Osei',
    'rating': 4,
    'text': 'Very patient and knowledgeable. Would definitely recommend.',
  },
  {
    'name': 'Priya Sharma',
    'rating': 5,
    'text': 'Explained complex concepts in a very clear way. 10/10!',
  },
];

class SkillDetailScreen extends StatelessWidget {
  final String skillId;

  const SkillDetailScreen({super.key, required this.skillId});

  @override
  Widget build(BuildContext context) {
    final skill = context.watch<SkillProvider>().findById(skillId);

    if (skill == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Skill not found')),
      );
    }

    final allSkills = context.watch<SkillProvider>().all;
    final otherSkills = allSkills
        .where((s) => s.userId == skill.userId && s.id != skill.id)
        .take(3)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              color: AppColors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  UserAvatar(name: skill.userName, size: 72),
                  const SizedBox(height: 12),
                  Text(skill.userName,
                      style: AppTextStyles.headlineMedium),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha:0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      skill.userCampus,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    skill.skillTitle,
                    style: AppTextStyles.displayMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),

                  // Info row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _InfoChip(
                        icon: Icons.laptop_outlined,
                        label: skill.mode,
                      ),
                      const SizedBox(width: 8),
                      _InfoChip(
                        icon: Icons.calendar_today_outlined,
                        label: skill.availability,
                        maxWidth: 140,
                      ),
                      const SizedBox(width: 8),
                      _InfoChip(
                        icon: Icons.repeat,
                        label: 'Max ${skill.maxSessionsPerWeek}/wk',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Description
            _Section(
              title: 'About this Skill',
              child: Text(
                skill.description,
                style: AppTextStyles.bodyMedium.copyWith(height: 1.6),
              ),
            ),
            const SizedBox(height: 8),

            // Rating
            _Section(
              title: 'Rating & Sessions',
              child: Row(
                children: [
                  Icon(Icons.star_rounded,
                      color: AppColors.accent, size: 28),
                  const SizedBox(width: 6),
                  Text(
                    skill.rating.toStringAsFixed(1),
                    style: AppTextStyles.headlineLarge
                        .copyWith(color: AppColors.accent),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '(${skill.sessionCount} sessions)',
                    style: AppTextStyles.bodySmall,
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: skill.isAvailable
                          ? const Color(0xFF4CAF50).withValues(alpha:0.12)
                          : AppColors.subtleText.withValues(alpha:0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: skill.isAvailable
                                ? const Color(0xFF4CAF50)
                                : AppColors.subtleText,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          skill.isAvailable ? 'Available' : 'Unavailable',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: skill.isAvailable
                                ? const Color(0xFF4CAF50)
                                : AppColors.subtleText,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Other skills from this person
            if (otherSkills.isNotEmpty) ...[
              _Section(
                title: 'Other skills from ${skill.userName.split(' ').first}',
                child: Column(
                  children: otherSkills
                      .map(
                        (s) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(s.skillTitle,
                              style: AppTextStyles.titleMedium),
                          subtitle: Text(s.category,
                              style: AppTextStyles.bodySmall),
                          trailing: Icon(Icons.arrow_forward_ios,
                              size: 14, color: AppColors.subtleText),
                          onTap: () => Navigator.pushReplacementNamed(
                            context,
                            '/skill-detail',
                            arguments: s.id,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: 8),
            ],

            // Reviews
            _Section(
              title: 'Reviews',
              child: Column(
                children: _mockReviews.map((review) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            UserAvatar(
                                name: review['name'] as String, size: 32),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                review['name'] as String,
                                style: AppTextStyles.titleMedium,
                              ),
                            ),
                            StarRatingBar(
                              rating: review['rating'] as int,
                              onRating: (_) {},
                              readOnly: true,
                              starSize: 16,
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          review['text'] as String,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.subtleText,
                          ),
                        ),
                        const Divider(height: 20),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            // Send Request button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _showRequestConfirmation(context, skill),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: Text(
                    'Send Request',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _showRequestConfirmation(BuildContext context, dynamic skill) {
    // Fire notification immediately when dialog opens (simulates push to poster)
    final requester = context.read<AuthProvider>().user;
    context.read<NotificationProvider>().addNotification(
          title: 'New Skill Request 🎓',
          body:
              '${requester?.fullName ?? 'A student'} requested your "${skill.skillTitle}" session. Check your chat!',
        );
    // Increment request count in provider
    skill.requestCount = (skill.requestCount as int) + 1;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('✅', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(
              'Request Sent to ${(skill.userName as String).split(' ').first}!',
              style: AppTextStyles.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              "${(skill.userName as String).split(' ').first} has been notified and will reach out via chat.",
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.subtleText),
            ),
            const SizedBox(height: 20),
            // Notification confirmation banner
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.notifications_active, color: Color(0xFF4CAF50), size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Notification sent to ${(skill.userName as String).split(' ').first}',
                      style: AppTextStyles.bodySmall.copyWith(color: const Color(0xFF2E7D32)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                    child: const Text('Close'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.pushNamed(
                        context,
                        '/chat-detail',
                        arguments: 'dm_${skill.userId}',
                      );
                    },
                    icon: const Icon(Icons.chat_bubble_outline, size: 16),
                    label: const Text('Open Chat'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final double? maxWidth;

  const _InfoChip({
    required this.icon,
    required this.label,
    this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      constraints:
          maxWidth != null ? BoxConstraints(maxWidth: maxWidth!) : null,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFDDDDDD)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.subtleText),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.darkText,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;

  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.headlineSmall),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
