import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/colors.dart';
import '../../constants/text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../providers/feed_provider.dart';
import '../../widgets/opportunity_card.dart';
import '../../widgets/shimmer_loader.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  bool _isGrid = false;
  String _activeFilter = 'All';

  static const _filters = ['All', 'Events', 'Hackathons', 'Internships', 'Workshops'];

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

    // Trending: top 3 by rsvpCount
    final trending = [...feedProvider.all]
      ..sort((a, b) => b.rsvpCount.compareTo(a.rsvpCount));
    final trendingTop3 = trending.take(3).toList();

    // Filtered list
    final filtered = feedProvider.filtered;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: false,
        title: TextField(
          controller: _searchCtrl,
          style: AppTextStyles.bodyMedium,
          onChanged: (q) {
            context.read<FeedProvider>().setSearch(q);
          },
          decoration: InputDecoration(
            hintText: 'Search opportunities...',
            hintStyle: AppTextStyles.bodySmall,
            prefixIcon: const Icon(Icons.search,
                color: AppColors.subtleText, size: 20),
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isGrid ? Icons.view_list : Icons.grid_view,
              color: AppColors.darkText,
            ),
            onPressed: () => setState(() => _isGrid = !_isGrid),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter chips
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: _filters.map((f) {
                  final isActive = _activeFilter == f;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _activeFilter = f);
                        context.read<FeedProvider>().setFilter(f);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 7),
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.primary
                              : AppColors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isActive
                                ? AppColors.primary
                                : const Color(0xFFDDDDDD),
                          ),
                        ),
                        child: Text(
                          f,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isActive
                                ? AppColors.white
                                : AppColors.darkText,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),

            // Trending this week
            if (trendingTop3.isNotEmpty && _searchCtrl.text.isEmpty) ...[
              Text('Trending This Week 🔥',
                  style: AppTextStyles.headlineSmall),
              const SizedBox(height: 10),
              SizedBox(
                height: 195,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: trendingTop3.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, i) => SizedBox(
                    width: 280,
                    child: OpportunityCard(opportunity: trendingTop3[i]),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Recommended for you
            Text('Recommended for You',
                style: AppTextStyles.headlineSmall),
            const SizedBox(height: 10),

            if (feedProvider.isLoading)
              const ShimmerLoader()
            else if (filtered.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: Column(
                    children: [
                      const Icon(Icons.search_off,
                          size: 48, color: AppColors.subtleText),
                      const SizedBox(height: 8),
                      Text(
                        'No opportunities found',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.subtleText,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else if (_isGrid)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.78,
                ),
                itemCount: filtered.length,
                itemBuilder: (context, i) => _GridOpportunityCard(
                  opportunity: filtered[i],
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filtered.length,
                itemBuilder: (context, i) =>
                    OpportunityCard(opportunity: filtered[i]),
              ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class _GridOpportunityCard extends StatelessWidget {
  final dynamic opportunity;

  const _GridOpportunityCard({required this.opportunity});

  @override
  Widget build(BuildContext context) {
    final catColor = AppColors.categoryColor(opportunity.category);
    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        '/opportunity-detail',
        arguments: opportunity.id,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 6,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 70,
              decoration: BoxDecoration(
                color: catColor.withOpacity(0.15),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              alignment: Alignment.center,
              child: Icon(Icons.event, color: catColor, size: 32),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    opportunity.category,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: catColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    opportunity.title,
                    style: AppTextStyles.titleMedium.copyWith(fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    opportunity.organizer,
                    style: AppTextStyles.bodySmall.copyWith(fontSize: 10),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
