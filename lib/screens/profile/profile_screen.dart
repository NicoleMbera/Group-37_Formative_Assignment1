import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../constants/colors.dart';
import '../../constants/text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/community_provider.dart';
import '../../providers/feed_provider.dart';
import '../../providers/rsvp_provider.dart';
import '../../providers/skill_provider.dart';
import '../../widgets/user_avatar.dart';
import '../../widgets/skill_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Profile', style: AppTextStyles.headlineLarge),
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: () =>
                Navigator.pushReplacementNamed(context, '/login'),
            child: const Text('Login'),
          ),
        ),
      );
    }

    final rsvpProvider = context.watch<RsvpProvider>();
    final communityProvider = context.watch<CommunityProvider>();
    final skillProvider = context.watch<SkillProvider>();
    final feedProvider = context.watch<FeedProvider>();

    final rsvpCount = rsvpProvider.goingEventIds.length;
    final joinedCount = communityProvider.joined.length;
    final mySkills = skillProvider.myListings(user.id);
    final myPosts = feedProvider.all
        .where((o) => o.organizer == user.fullName)
        .toList();
    final pastMyPosts = myPosts.where((o) => o.isPast).toList();

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          centerTitle: false,
          title: Text('Profile', style: AppTextStyles.headlineLarge),
          actions: [
            const _ProfileMenuButton(),
          ],
          bottom: TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.subtleText,
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            isScrollable: true,
            labelStyle: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
            unselectedLabelStyle: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
            tabs: const [
              Tab(text: 'My Posts'),
              Tab(text: 'Saved'),
              Tab(text: 'My Skills'),
              Tab(text: 'Notifications'),
            ],
          ),
        ),
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  // Profile header
                  Container(
                    color: AppColors.white,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        UserAvatar(
                            name: user.fullName,
                            imageUrl: user.avatarUrl,
                            size: 80),
                        const SizedBox(height: 12),
                        Text(user.fullName,
                            style: AppTextStyles.headlineLarge),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _RoleBadge(role: user.role),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: const Color(0xFFDDDDDD)),
                              ),
                              child: Text(
                                user.campus,
                                style: AppTextStyles.bodySmall.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          user.pathway,
                          style: AppTextStyles.bodySmall,
                        ),
                        const SizedBox(height: 16),

                        // Stats row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _StatItem(
                                count: rsvpCount, label: 'Events'),
                            _Divider(),
                            _StatItem(
                                count: joinedCount,
                                label: 'Communities'),
                            _Divider(),
                            _StatItem(
                                count: mySkills.length,
                                label: 'Skills'),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Organizer: My Events section
                  if (user.isOrganizer && pastMyPosts.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      color: AppColors.white,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('My Events',
                              style: AppTextStyles.headlineSmall),
                          const SizedBox(height: 10),
                          ...pastMyPosts.map(
                            (opp) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(opp.title,
                                  style: AppTextStyles.titleMedium),
                              subtitle: Text(
                                DateFormat('MMM d, yyyy')
                                    .format(opp.date),
                                style: AppTextStyles.bodySmall,
                              ),
                              trailing: OutlinedButton(
                                onPressed: () => Navigator.pushNamed(
                                  context,
                                  '/feedback-analytics',
                                  arguments: opp.id,
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.primary,
                                  side: const BorderSide(
                                      color: AppColors.primary),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(16),
                                  ),
                                ),
                                child: Text(
                                  'Analytics',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
          body: TabBarView(
            children: [
              // My Posts
              myPosts.isEmpty
                  ? _EmptyState(
                      icon: Icons.post_add_outlined,
                      message: user.isOrganizer
                          ? 'No posts yet. Create your first event!'
                          : 'You haven\'t posted anything yet.',
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: myPosts.length,
                      itemBuilder: (context, i) {
                        final opp = myPosts[i];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(opp.title,
                                  style: AppTextStyles.titleMedium),
                              const SizedBox(height: 4),
                              Text(
                                '${opp.category} · ${DateFormat('MMM d').format(opp.date)}',
                                style: AppTextStyles.bodySmall,
                              ),
                              Text(
                                '${opp.rsvpCount} RSVPs',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

              // Saved
              const _EmptyState(
                icon: Icons.bookmark_border_outlined,
                message: 'Saved items — coming soon!',
              ),

              // My Skills
              mySkills.isEmpty
                  ? _EmptyState(
                      icon: Icons.lightbulb_outline,
                      message: 'You haven\'t listed any skills yet.',
                      actionLabel: 'Offer a Skill',
                      onAction: () =>
                          Navigator.pushNamed(context, '/offer-skill'),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: mySkills.length,
                      itemBuilder: (context, i) =>
                          SkillCard(skill: mySkills[i]),
                    ),

              // Notifications
              _NotificationsTab(),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileMenuButton extends StatelessWidget {
  const _ProfileMenuButton();

  @override
  Widget build(BuildContext context) {
    final unreadCount = context.watch<NotificationProvider>().unreadCount;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: PopupMenuButton<String>(
        offset: const Offset(0, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: AppColors.white,
        elevation: 4,
        onSelected: (value) => _handleSelection(context, value),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFEEEEEE)),
          ),
          child: const Icon(
            Icons.more_horiz,
            color: AppColors.darkText,
            size: 22,
          ),
        ),
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 'account',
            child: _ProfileMenuItem(
              icon: Icons.account_circle_outlined,
              label: 'Account',
            ),
          ),
          PopupMenuItem(
            value: 'notifications',
            child: _ProfileMenuItem(
              icon: Icons.notifications_outlined,
              label: 'Notifications',
              badge: unreadCount > 0 ? unreadCount : null,
            ),
          ),
          PopupMenuItem(
            value: 'help',
            child: _ProfileMenuItem(
              icon: Icons.help_outline,
              label: 'Help & Support',
            ),
          ),
          const PopupMenuDivider(height: 1),
          PopupMenuItem(
            value: 'logout',
            child: _ProfileMenuItem(
              icon: Icons.logout,
              label: 'Logout',
              color: AppColors.error,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSelection(BuildContext context, String value) async {
    switch (value) {
      case 'account':
        Navigator.pushNamed(context, '/account');
      case 'notifications':
        Navigator.pushNamed(context, '/notifications');
      case 'help':
        Navigator.pushNamed(context, '/help-support');
      case 'logout':
        await context.read<AuthProvider>().logout();
        if (context.mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
    }
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final int? badge;

  const _ProfileMenuItem({
    required this.icon,
    required this.label,
    this.color,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = color ?? AppColors.darkText;
    return Row(
      children: [
        Icon(icon, size: 20, color: textColor),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        if (badge != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$badge',
              style: GoogleFonts.poppins(
                color: AppColors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }
}

class _NotificationsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final notifications = context.watch<NotificationProvider>().all;
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: notifications.length,
      separatorBuilder: (_, __) => const Divider(height: 0.5, indent: 16),
      itemBuilder: (context, i) {
        final n = notifications[i];
        final isUnread = !n.isRead;
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          tileColor: isUnread ? AppColors.primary.withValues(alpha: 0.04) : null,
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isUnread ? AppColors.primary.withValues(alpha: 0.1) : AppColors.surface,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_outlined,
              color: isUnread ? AppColors.primary : AppColors.subtleText,
              size: 20,
            ),
          ),
          title: Text(
            n.title,
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: isUnread ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          subtitle: Text(n.body, style: AppTextStyles.bodySmall),
          trailing: Text(_formatTime(n.time), style: AppTextStyles.labelSmall),
          onTap: () => context.read<NotificationProvider>().markRead(n.id),
        );
      },
    );
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'now';
  }
}

class _RoleBadge extends StatelessWidget {
  final String role;

  const _RoleBadge({required this.role});

  Color get _color {
    switch (role) {
      case 'Event Organizer':
        return const Color(0xFF1565C0);
      case 'Club Leader':
        return const Color(0xFF6A1B9A);
      case 'Academic Staff':
        return const Color(0xFF2E7D32);
      case 'Entrepreneur':
        return AppColors.accent;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        role,
        style: AppTextStyles.bodySmall.copyWith(
          color: _color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final int count;
  final String label;

  const _StatItem({required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$count',
          style: AppTextStyles.headlineLarge.copyWith(
            color: AppColors.primary,
          ),
        ),
        Text(label, style: AppTextStyles.bodySmall),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 32,
      color: const Color(0xFFEEEEEE),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _EmptyState({
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: AppColors.subtleText),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.subtleText,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
