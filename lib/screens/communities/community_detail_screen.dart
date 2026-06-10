import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/colors.dart';
import '../../constants/text_styles.dart';
import '../../providers/community_provider.dart';
import '../../providers/feed_provider.dart';
import '../../widgets/opportunity_card.dart';

class CommunityDetailScreen extends StatelessWidget {
  final String id;

  const CommunityDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    final community = context.watch<CommunityProvider>().findById(id);

    if (community == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Community not found')),
      );
    }

    final isJoined = context.watch<CommunityProvider>().isJoined(id);
    final feedProvider = context.watch<FeedProvider>();

    // Filter events by community organizer name
    final relatedEvents = feedProvider.all
        .where((o) =>
            o.organizer.toLowerCase() == community.name.toLowerCase() ||
            o.tags.any((t) =>
                community.tags
                    .any((ct) => ct.toLowerCase() == t.toLowerCase())))
        .toList();

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: AppColors.primary,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 50),
                    Text(
                      community.iconEmoji,
                      style: const TextStyle(fontSize: 64),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      community.name,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                    ),
                  ],
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
                  // Description
                  Text(community.description,
                      style: AppTextStyles.bodyMedium.copyWith(height: 1.6)),
                  const SizedBox(height: 16),

                  // Stats row
                  Row(
                    children: [
                      _StatPill(
                        icon: Icons.people_outline,
                        label: '${community.memberCount} members',
                      ),
                      const SizedBox(width: 10),
                      _StatPill(
                        icon: Icons.public,
                        label: community.campus,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Tags
                  if (community.tags.isNotEmpty) ...[
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: community.tags
                          .map((tag) => Chip(
                                label: Text(
                                  tag,
                                  style: AppTextStyles.labelSmall
                                      .copyWith(color: AppColors.darkText),
                                ),
                                backgroundColor: AppColors.surface,
                                side: const BorderSide(
                                    color: Color(0xFFDDDDDD)),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Join / Leave + Chat buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => context
                              .read<CommunityProvider>()
                              .toggleJoin(id),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isJoined
                                ? AppColors.subtleText
                                : AppColors.primary,
                            foregroundColor: AppColors.white,
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: Text(
                            isJoined ? 'Leave Community' : 'Join Community',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: () => Navigator.pushNamed(
                          context,
                          '/chat-detail',
                          arguments: community.id,
                        ),
                        icon: const Icon(Icons.chat_outlined, size: 18),
                        label: const Text('Chat'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Events from this community
                  Text('Events & Activities',
                      style: AppTextStyles.headlineSmall),
                  const SizedBox(height: 10),
                  if (relatedEvents.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: Text(
                          'No events from this community yet.',
                          style: AppTextStyles.bodySmall,
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: relatedEvents.length,
                      itemBuilder: (context, i) =>
                          OpportunityCard(opportunity: relatedEvents[i]),
                    ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFDDDDDD)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.subtleText),
          const SizedBox(width: 5),
          Text(label,
              style: AppTextStyles.bodySmall
                  .copyWith(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
