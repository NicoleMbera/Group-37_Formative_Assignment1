import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';

import '../../constants/colors.dart';
import '../../constants/text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../providers/feed_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/rsvp_provider.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/opportunity_card.dart';
import '../../widgets/shimmer_loader.dart';
import '../campus_pulse/campus_pulse_screen.dart';
import '../communities/communities_screen.dart';
import '../explore/explore_screen.dart';
import '../profile/profile_screen.dart';
import '../skills/skills_marketplace_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  List<Widget> get _tabs {
    final user = context.read<AuthProvider>().user;
    final homeTab =
        (user != null && user.isOrganizer) ? const _OrganizerDashboard() : const _StudentHomeTab();
    return [
      homeTab,
      const ExploreScreen(),
      const SkillsMarketplaceScreen(),
      const CommunitiesScreen(),
      const CampusPulseScreen(),
      const ProfileScreen(),
    ];
  }

  void _onFabTap() {
    final user = context.read<AuthProvider>().user;
    if (user == null) return;
    if (!user.isOrganizer) {
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (_) => Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_outline, size: 48, color: AppColors.subtleText),
              const SizedBox(height: 16),
              Text('Organisers Only', style: AppTextStyles.headlineMedium),
              const SizedBox(height: 8),
              Text(
                'Only Club Leaders, Event Organisers, and Academic Staff can post opportunities.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.subtleText),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  child: const Text('Got it'),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      Navigator.pushNamed(context, '/create-post');
    }
  }

  @override
  Widget build(BuildContext context) {
    final tabs = _tabs;
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: tabs),
      floatingActionButton: FloatingActionButton(
        onPressed: _onFabTap,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        color: AppColors.white,
        elevation: 8,
        padding: EdgeInsets.zero, // let the Row control its own padding
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(icon: Icons.home_outlined,    activeIcon: Icons.home,       label: 'Home',       index: 0, current: _currentIndex, onTap: (i) => setState(() => _currentIndex = i)),
            _NavItem(icon: Icons.explore_outlined, activeIcon: Icons.explore,    label: 'Explore',    index: 1, current: _currentIndex, onTap: (i) => setState(() => _currentIndex = i)),
            _NavItem(icon: Icons.school_outlined,  activeIcon: Icons.school,     label: 'Skills',     index: 2, current: _currentIndex, onTap: (i) => setState(() => _currentIndex = i)),
            const SizedBox(width: 48), // FAB notch gap
            _NavItem(icon: Icons.group_outlined,   activeIcon: Icons.group,      label: 'Clubs',      index: 3, current: _currentIndex, onTap: (i) => setState(() => _currentIndex = i)),
            _NavItem(icon: Icons.bar_chart_outlined,activeIcon: Icons.bar_chart, label: 'Pulse',      index: 4, current: _currentIndex, onTap: (i) => setState(() => _currentIndex = i)),
            _NavItem(icon: Icons.person_outline,   activeIcon: Icons.person,     label: 'Profile',    index: 5, current: _currentIndex, onTap: (i) => setState(() => _currentIndex = i)),
          ],
        ),
      ),
    );
  }
}

// ─── Nav item ─────────────────────────────────────────────────────────────────

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int index;
  final int current;
  final void Function(int) onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.index,
    required this.current,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = index == current;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? AppColors.primary : AppColors.subtleText,
              size: 22,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: isActive ? AppColors.primary : AppColors.subtleText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Student Home Tab ─────────────────────────────────────────────────────────

class _StudentHomeTab extends StatefulWidget {
  const _StudentHomeTab();

  @override
  State<_StudentHomeTab> createState() => _StudentHomeTabState();
}

class _StudentHomeTabState extends State<_StudentHomeTab> {
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().user;
      context.read<FeedProvider>().loadFeed(user);
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final feedProvider = context.watch<FeedProvider>();
    final notifProvider = context.watch<NotificationProvider>();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          'ALU Connect',
          style: AppTextStyles.headlineLarge.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: AppColors.darkText),
                onPressed: () {},
              ),
              if (notifProvider.unreadCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                    child: Center(
                      child: Text(
                        '${notifProvider.unreadCount}',
                        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () {
          final user = context.read<AuthProvider>().user;
          return context.read<FeedProvider>().loadFeed(user);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting
              Consumer<AuthProvider>(
                builder: (_, auth, __) => Text(
                  'Hi, ${auth.user?.fullName.split(' ').first ?? 'there'} 👋',
                  style: AppTextStyles.displayMedium,
                ),
              ),
              const SizedBox(height: 4),
              Text('What\'s happening at ALU today?', style: AppTextStyles.bodySmall),
              const SizedBox(height: 16),

              // Search bar
              TextField(
                controller: _searchCtrl,
                onChanged: (q) => context.read<FeedProvider>().setSearch(q),
                decoration: InputDecoration(
                  hintText: 'Search events, clubs...',
                  prefixIcon: const Icon(Icons.search, color: AppColors.subtleText, size: 20),
                  filled: true,
                  fillColor: AppColors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Category filter chips
              SizedBox(
                height: 36,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: ['All', 'Events', 'Hackathons', 'Internships', 'Workshops']
                      .map((cat) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: CategoryChip(
                              category: cat,
                              selected: feedProvider.filter == cat,
                              onTap: () => context.read<FeedProvider>().setFilter(cat),
                            ),
                          ))
                      .toList(),
                ),
              ),
              const SizedBox(height: 20),

              // My RSVPs
              _SectionHeader(title: 'My RSVPs'),
              const SizedBox(height: 10),
              Consumer<RsvpProvider>(
                builder: (context, rsvpProvider, _) {
                  final goingIds = rsvpProvider.goingEventIds;
                  if (goingIds.isEmpty) {
                    return _EmptyState(
                      icon: Icons.event_available_outlined,
                      message: "You haven't RSVP'd yet. Explore events →",
                    );
                  }
                  final events = goingIds
                      .map((id) => feedProvider.findById(id))
                      .where((o) => o != null)
                      .toList();
                  return SizedBox(
                    height: 90,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: events.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (_, i) => _RsvpMiniCard(opportunity: events[i]!),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              // Top Matches
              _SectionHeader(title: 'Matched for You ⚡'),
              const SizedBox(height: 10),
              if (feedProvider.isLoading)
                const ShimmerLoader()
              else if (feedProvider.topMatches.isEmpty)
                _EmptyState(icon: Icons.star_outline, message: 'Loading your matches...')
              else
                SizedBox(
                  height: 195,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: feedProvider.topMatches.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (_, i) => SizedBox(
                      width: 280,
                      child: OpportunityCard(opportunity: feedProvider.topMatches[i]),
                    ),
                  ),
                ),
              const SizedBox(height: 20),

              // Latest Opportunities
              _SectionHeader(title: 'Latest Opportunities'),
              const SizedBox(height: 10),
              if (feedProvider.isLoading)
                const ShimmerLoader()
              else if (feedProvider.filtered.isEmpty)
                _EmptyState(icon: Icons.search_off, message: 'No opportunities found')
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: feedProvider.filtered.length,
                  itemBuilder: (_, i) => OpportunityCard(opportunity: feedProvider.filtered[i]),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Organiser Dashboard Tab ──────────────────────────────────────────────────

class _OrganizerDashboard extends StatefulWidget {
  const _OrganizerDashboard();

  @override
  State<_OrganizerDashboard> createState() => _OrganizerDashboardState();
}

class _OrganizerDashboardState extends State<_OrganizerDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().user;
      context.read<FeedProvider>().loadFeed(user);
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final feed = context.watch<FeedProvider>();
    final user = auth.user;
    final notifProvider = context.watch<NotificationProvider>();

    // Events posted by this organiser (mock: match organizer name to user name)
    final myEvents = feed.all.where((o) {
      final orgLower = o.organizer.toLowerCase();
      final nameLower = (user?.fullName ?? '').toLowerCase();
      // Match on first name or last name
      return nameLower.split(' ').any((part) => part.length > 2 && orgLower.contains(part));
    }).toList();

    final totalRsvps = myEvents.fold(0, (sum, e) => sum + e.rsvpCount);
    final pastEvents = myEvents.where((e) => e.isPast).toList();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          'ALU Connect',
          style: AppTextStyles.headlineLarge.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: AppColors.darkText),
                onPressed: () {},
              ),
              if (notifProvider.unreadCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                    child: Center(
                      child: Text(
                        '${notifProvider.unreadCount}',
                        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () {
          final u = context.read<AuthProvider>().user;
          return context.read<FeedProvider>().loadFeed(u);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hi, ${user?.fullName.split(' ').first ?? 'Organiser'} 👋',
                          style: AppTextStyles.displayMedium,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            user?.role ?? 'Organiser',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Quick stats row
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'My Events',
                      value: '${myEvents.length}',
                      icon: Icons.event,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatCard(
                      label: 'Total RSVPs',
                      value: '$totalRsvps',
                      icon: Icons.people,
                      color: const Color(0xFF1565C0),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatCard(
                      label: 'Past Events',
                      value: '${pastEvents.length}',
                      icon: Icons.history,
                      color: const Color(0xFF2E7D32),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Post new event CTA
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, Color(0xFF8B0B1E)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Post an Event', style: AppTextStyles.headlineSmall.copyWith(color: AppColors.white)),
                          const SizedBox(height: 4),
                          Text(
                            'Share opportunities with the ALU community',
                            style: AppTextStyles.bodySmall.copyWith(color: AppColors.white.withValues(alpha: 0.85)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () => Navigator.pushNamed(context, '/create-post'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.white,
                        foregroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      ),
                      child: Text('Post Now', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // My Posted Events
              _SectionHeader(title: 'My Posted Events'),
              const SizedBox(height: 12),
              if (feed.isLoading)
                const ShimmerLoader()
              else if (myEvents.isEmpty)
                _EmptyState(icon: Icons.event_note_outlined, message: "No events posted yet. Tap 'Post Now' to get started.")
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: myEvents.length,
                  itemBuilder: (_, i) => _OrganizerEventCard(event: myEvents[i]),
                ),
              const SizedBox(height: 24),

              // Quick access to analytics for past events
              if (pastEvents.isNotEmpty) ...[
                _SectionHeader(title: 'Event Analytics'),
                const SizedBox(height: 12),
                ...pastEvents.map(
                  (e) => _AnalyticsShortcutTile(event: e),
                ),
              ],

              const SizedBox(height: 24),

              // Recent feed (shared with students)
              _SectionHeader(title: 'All Campus Events'),
              const SizedBox(height: 10),
              if (feed.isLoading)
                const ShimmerLoader()
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: feed.upcomingOnly.take(5).length,
                  itemBuilder: (_, i) => OpportunityCard(opportunity: feed.upcomingOnly[i]),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(value, style: AppTextStyles.displayMedium.copyWith(color: color)),
          Text(label, style: AppTextStyles.labelSmall),
        ],
      ),
    );
  }
}

class _OrganizerEventCard extends StatelessWidget {
  final dynamic event;

  const _OrganizerEventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final catColor = AppColors.categoryColor(event.category as String);
    final capacity = event.maxParticipants as int;
    final rsvps = event.rsvpCount as int;
    final ratio = capacity > 0 ? rsvps / capacity : 0.0;
    final isPast = event.isPast as bool;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border(left: BorderSide(color: catColor, width: 4)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(event.title as String, style: AppTextStyles.headlineSmall),
                ),
                if (isPast)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.subtleText.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('Past', style: AppTextStyles.labelSmall),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('Live', style: AppTextStyles.labelSmall.copyWith(color: const Color(0xFF4CAF50), fontWeight: FontWeight.w700)),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 13, color: AppColors.subtleText),
                const SizedBox(width: 4),
                Text(DateFormat('MMM d, yyyy').format(event.date as DateTime), style: AppTextStyles.bodySmall),
                const SizedBox(width: 12),
                const Icon(Icons.location_on_outlined, size: 13, color: AppColors.subtleText),
                const SizedBox(width: 4),
                Expanded(child: Text(event.location as String, style: AppTextStyles.bodySmall, overflow: TextOverflow.ellipsis)),
              ],
            ),
            const SizedBox(height: 10),

            // RSVP capacity bar
            Row(
              children: [
                Text('$rsvps / $capacity RSVPs', style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600)),
                const Spacer(),
                if (ratio >= 0.8)
                  Text('Filling up! 🔴', style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary)),
              ],
            ),
            const SizedBox(height: 6),
            LinearPercentIndicator(
              padding: EdgeInsets.zero,
              lineHeight: 6,
              percent: ratio.clamp(0.0, 1.0),
              backgroundColor: AppColors.surface,
              progressColor: ratio >= 0.8 ? AppColors.primary : const Color(0xFF4CAF50),
              barRadius: const Radius.circular(4),
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pushNamed(context, '/opportunity-detail', arguments: event.id as String),
                    icon: const Icon(Icons.visibility_outlined, size: 16),
                    label: const Text('View'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      textStyle: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                if (isPast) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pushNamed(context, '/feedback-analytics', arguments: event.id as String),
                      icon: const Icon(Icons.bar_chart, size: 16),
                      label: const Text('Analytics'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        textStyle: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AnalyticsShortcutTile extends StatelessWidget {
  final dynamic event;

  const _AnalyticsShortcutTile({required this.event});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      tileColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.analytics_outlined, color: AppColors.primary, size: 20),
      ),
      title: Text(event.title as String, style: AppTextStyles.titleMedium),
      subtitle: Text(
        '${event.rsvpCount} attended · ${DateFormat('MMM d').format(event.date as DateTime)}',
        style: AppTextStyles.bodySmall,
      ),
      trailing: const Icon(Icons.chevron_right, color: AppColors.subtleText),
      onTap: () => Navigator.pushNamed(context, '/feedback-analytics', arguments: event.id as String),
    );
  }
}

// ─── Shared helpers ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) => Text(title, style: AppTextStyles.headlineSmall);
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.subtleText),
          const SizedBox(width: 8),
          Expanded(child: Text(message, style: AppTextStyles.bodySmall)),
        ],
      ),
    );
  }
}

class _RsvpMiniCard extends StatelessWidget {
  final dynamic opportunity;

  const _RsvpMiniCard({required this.opportunity});

  @override
  Widget build(BuildContext context) {
    final catColor = AppColors.categoryColor(opportunity.category as String);
    return Container(
      width: 180,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border(left: BorderSide(color: catColor, width: 3)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6, offset: const Offset(0, 1)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            opportunity.title as String,
            style: AppTextStyles.titleMedium.copyWith(fontSize: 12),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.12),
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
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  DateFormat('MMM d').format(opportunity.date as DateTime),
                  style: AppTextStyles.bodySmall.copyWith(fontSize: 10),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
