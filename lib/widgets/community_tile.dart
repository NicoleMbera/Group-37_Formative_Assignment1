import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';
import '../models/community.dart';
import '../providers/community_provider.dart';

class CommunityTile extends StatelessWidget {
  final Community community;
  final VoidCallback? onTap;

  const CommunityTile({
    super.key,
    required this.community,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<CommunityProvider>(
      builder: (context, communityProvider, _) {
        final isJoined = communityProvider.isJoined(community.id);
        return ListTile(
          onTap: onTap ??
              () => Navigator.pushNamed(
                    context,
                    '/community-detail',
                    arguments: community.id,
                  ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              community.iconEmoji,
              style: const TextStyle(fontSize: 22),
            ),
          ),
          title: Text(community.name, style: AppTextStyles.titleMedium),
          subtitle: Text(
            '${community.memberCount} members',
            style: AppTextStyles.bodySmall,
          ),
          trailing: OutlinedButton(
            onPressed: () =>
                communityProvider.toggleJoin(community.id),
            style: OutlinedButton.styleFrom(
              foregroundColor:
                  isJoined ? AppColors.subtleText : AppColors.primary,
              side: BorderSide(
                color: isJoined ? AppColors.subtleText : AppColors.primary,
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              isJoined ? 'Joined' : 'Join',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isJoined ? AppColors.subtleText : AppColors.primary,
              ),
            ),
          ),
        );
      },
    );
  }
}
