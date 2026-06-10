import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/colors.dart';
import '../../constants/text_styles.dart';
import '../../providers/community_provider.dart';
import '../../widgets/community_tile.dart';

class CommunitiesScreen extends StatelessWidget {
  const CommunitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          centerTitle: false,
          title:
              Text('Communities', style: AppTextStyles.headlineLarge),
          bottom: TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.subtleText,
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            labelStyle: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            unselectedLabelStyle: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
            tabs: const [
              Tab(text: 'All Clubs'),
              Tab(text: 'My Clubs'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _AllCommunities(),
            _MyCommunities(),
          ],
        ),
      ),
    );
  }
}

class _AllCommunities extends StatelessWidget {
  const _AllCommunities();

  @override
  Widget build(BuildContext context) {
    final communities = context.watch<CommunityProvider>().all;
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: communities.length,
      separatorBuilder: (_, __) => const Divider(height: 0.5, indent: 16),
      itemBuilder: (context, i) => CommunityTile(
        community: communities[i],
      ),
    );
  }
}

class _MyCommunities extends StatelessWidget {
  const _MyCommunities();

  @override
  Widget build(BuildContext context) {
    final joined = context.watch<CommunityProvider>().joined;
    if (joined.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.group_outlined,
                  size: 64, color: AppColors.subtleText),
              const SizedBox(height: 16),
              Text(
                'No clubs yet',
                style: AppTextStyles.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Join clubs to see them here and stay connected.',
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
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: joined.length,
      separatorBuilder: (_, __) => const Divider(height: 0.5, indent: 16),
      itemBuilder: (context, i) => CommunityTile(
        community: joined[i],
      ),
    );
  }
}
