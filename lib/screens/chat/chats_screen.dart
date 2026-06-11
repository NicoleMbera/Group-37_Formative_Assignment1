import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/colors.dart';
import '../../constants/text_styles.dart';
import '../../providers/community_provider.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final communityProvider = context.watch<CommunityProvider>();
    final joined = communityProvider.joined;

    final filtered = _searchQuery.isEmpty
        ? joined
        : joined
            .where((c) => c.name
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()))
            .toList();

    final mockLastMessages = {
      'com_001': "Let's meet Thursday at 4pm 🚀",
      'com_002': 'New funding opportunity posted!',
      'com_003': 'Great leadership talk today 🌟',
      'com_004': 'Next showcase is Friday evening',
      'com_005': 'Tree planting this Saturday!',
      'com_006': 'Yoga session at 7am tomorrow 🧘',
    };

    final mockTimes = {
      'com_001': DateTime.now().subtract(const Duration(minutes: 10)),
      'com_002': DateTime.now().subtract(const Duration(hours: 1)),
      'com_003': DateTime.now().subtract(const Duration(hours: 3)),
      'com_004': DateTime.now().subtract(const Duration(hours: 5)),
      'com_005': DateTime.now().subtract(const Duration(days: 1)),
      'com_006': DateTime.now().subtract(const Duration(days: 1, hours: 4)),
    };

    // Mock DM thread using first joined community as a "direct" thread
    final dmThread = joined.isNotEmpty ? joined.first : null;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: false,
        title: Text('Chats', style: AppTextStyles.headlineLarge),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              controller: _searchCtrl,
              style: AppTextStyles.bodyMedium,
              onChanged: (q) => setState(() => _searchQuery = q),
              decoration: InputDecoration(
                hintText: 'Search chats...',
                hintStyle: AppTextStyles.bodySmall,
                prefixIcon: const Icon(Icons.search,
                    color: AppColors.subtleText, size: 20),
                filled: true,
                fillColor: AppColors.white,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: joined.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.chat_outlined,
                              size: 64, color: AppColors.subtleText),
                          const SizedBox(height: 16),
                          Text(
                            'No chats yet',
                            style: AppTextStyles.headlineMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Join a community to start chatting.',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.subtleText,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView(
                    children: [
                      // Direct Messages section
                      if (dmThread != null && _searchQuery.isEmpty) ...[
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(16, 12, 16, 6),
                          child: Text(
                            'DIRECT MESSAGES',
                            style: AppTextStyles.labelSmall.copyWith(
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        _ChatTile(
                          emoji: '💬',
                          name:
                              '${dmThread.iconEmoji} ${dmThread.name} (DM)',
                          lastMessage: 'Thanks for the session!',
                          time: DateTime.now()
                              .subtract(const Duration(hours: 2)),
                          unread: 1,
                          onTap: () => Navigator.pushNamed(
                            context,
                            '/chat-detail',
                            arguments: 'dm_${dmThread.id}',
                          ),
                        ),
                        const Divider(height: 0.5, indent: 16),
                      ],

                      // Community chats section
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(16, 12, 16, 6),
                        child: Text(
                          'COMMUNITY CHATS',
                          style: AppTextStyles.labelSmall.copyWith(
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),

                      ...filtered.map((community) {
                        final lastMsg = mockLastMessages[community.id] ??
                            'No messages yet';
                        final msgTime =
                            mockTimes[community.id] ?? DateTime.now();
                        return Column(
                          children: [
                            _ChatTile(
                              emoji: community.iconEmoji,
                              name: community.name,
                              lastMessage: lastMsg,
                              time: msgTime,
                              unread: 0,
                              onTap: () => Navigator.pushNamed(
                                context,
                                '/chat-detail',
                                arguments: community.id,
                              ),
                            ),
                            const Divider(height: 0.5, indent: 16),
                          ],
                        );
                      }),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _ChatTile extends StatelessWidget {
  final String emoji;
  final String name;
  final String lastMessage;
  final DateTime time;
  final int unread;
  final VoidCallback onTap;

  const _ChatTile({
    required this.emoji,
    required this.name,
    required this.lastMessage,
    required this.time,
    required this.unread,
    required this.onTap,
  });

  String _formatTime() {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inDays > 0) return '${diff.inDays}d';
    if (diff.inHours > 0) return '${diff.inHours}h';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m';
    return 'now';
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
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
        child: Text(emoji, style: const TextStyle(fontSize: 22)),
      ),
      title: Text(name, style: AppTextStyles.titleMedium),
      subtitle: Text(
        lastMessage,
        style: AppTextStyles.bodySmall.copyWith(
          color: unread > 0 ? AppColors.darkText : AppColors.subtleText,
          fontWeight:
              unread > 0 ? FontWeight.w600 : FontWeight.w400,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(_formatTime(), style: AppTextStyles.labelSmall),
          if (unread > 0) ...[
            const SizedBox(height: 4),
            Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                '$unread',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.white,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
