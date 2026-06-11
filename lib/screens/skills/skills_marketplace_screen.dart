import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/colors.dart';
import '../../constants/text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../providers/skill_provider.dart';
import '../../widgets/skill_card.dart';
import '../../widgets/shimmer_loader.dart';

class SkillsMarketplaceScreen extends StatefulWidget {
  const SkillsMarketplaceScreen({super.key});

  @override
  State<SkillsMarketplaceScreen> createState() =>
      _SkillsMarketplaceScreenState();
}

class _SkillsMarketplaceScreenState extends State<SkillsMarketplaceScreen> {
  final TextEditingController _searchCtrl = TextEditingController();

  static const _filters = ['All', 'Tech', 'Design', 'Writing', 'Speaking', 'Career'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SkillProvider>().loadSkills();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

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
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Skills Exchange 🤝', style: AppTextStyles.headlineLarge),
              Text(
                'Learn from and teach your peers',
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
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
              Tab(text: 'Find Help'),
              Tab(text: 'Offer Skills'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _FindHelpTab(
              searchCtrl: _searchCtrl,
              filters: _filters,
            ),
            const _OfferSkillsTab(),
          ],
        ),
      ),
    );
  }
}

class _FindHelpTab extends StatefulWidget {
  final TextEditingController searchCtrl;
  final List<String> filters;

  const _FindHelpTab({
    required this.searchCtrl,
    required this.filters,
  });

  @override
  State<_FindHelpTab> createState() => _FindHelpTabState();
}

class _FindHelpTabState extends State<_FindHelpTab> {
  String _activeFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final skillProvider = context.watch<SkillProvider>();
    final skills = skillProvider.filtered;

    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: TextField(
            controller: widget.searchCtrl,
            style: AppTextStyles.bodyMedium,
            onChanged: (q) => context.read<SkillProvider>().setSearch(q),
            decoration: InputDecoration(
              hintText: 'Search skills or people...',
              hintStyle: AppTextStyles.bodySmall,
              prefixIcon: const Icon(Icons.search,
                  color: AppColors.subtleText, size: 20),
              filled: true,
              fillColor: AppColors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Filter chips
        SizedBox(
          height: 36,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: widget.filters.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final f = widget.filters[i];
              final isActive = _activeFilter == f;
              return GestureDetector(
                onTap: () {
                  setState(() => _activeFilter = f);
                  context.read<SkillProvider>().setFilter(f);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.primary : AppColors.white,
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
              );
            },
          ),
        ),
        const SizedBox(height: 10),

        // Skills list
        Expanded(
          child: skillProvider.isLoading
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: ShimmerLoader(),
                )
              : skills.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.school_outlined,
                              size: 48, color: AppColors.subtleText),
                          const SizedBox(height: 8),
                          Text(
                            'No skills found',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.subtleText,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: skills.length,
                      itemBuilder: (context, i) =>
                          SkillCard(skill: skills[i]),
                    ),
        ),
      ],
    );
  }
}

class _OfferSkillsTab extends StatelessWidget {
  const _OfferSkillsTab();

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final skillProvider = context.watch<SkillProvider>();
    final mySkills = user != null
        ? skillProvider.myListings(user.id)
        : <dynamic>[];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () =>
                  Navigator.pushNamed(context, '/offer-skill'),
              icon: const Icon(Icons.add),
              label: const Text('Offer a Skill'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
            ),
          ),
        ),
        if (mySkills.isEmpty)
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lightbulb_outline,
                        size: 64, color: AppColors.subtleText),
                    const SizedBox(height: 16),
                    Text(
                      'You haven\'t offered any skills yet',
                      style: AppTextStyles.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Share your knowledge and help fellow students grow.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.subtleText),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: mySkills.length,
              itemBuilder: (context, i) {
                final skill = mySkills[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
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
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              skill.skillTitle,
                              style: AppTextStyles.headlineSmall,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${skill.requestCount} requests',
                              style: AppTextStyles.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: skill.isAvailable,
                        activeColor: AppColors.primary,
                        onChanged: (_) => context
                            .read<SkillProvider>()
                            .toggleAvailability(skill.id),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
