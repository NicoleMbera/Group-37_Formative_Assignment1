import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../constants/colors.dart';
import '../../constants/text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/community_provider.dart';

class ChatDetailScreen extends StatefulWidget {
  final String threadId;

  const ChatDetailScreen({super.key, required this.threadId});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  String _threadName = '';
  bool _initialized = false;
  final TextEditingController _msgCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  String get _threadId => widget.threadId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _loadThreadName();
      context.read<ChatProvider>().loadMessages(_threadId).then((_) {
        _scrollToBottom();
      });
    }
  }

  void _loadThreadName() {
    if (_threadId.startsWith('dm_')) {
      final communityId = _threadId.replaceFirst('dm_', '');
      final community =
          context.read<CommunityProvider>().findById(communityId);
      _threadName = community != null
          ? '${community.iconEmoji} ${community.name}'
          : 'Direct Message';
    } else {
      final community =
          context.read<CommunityProvider>().findById(_threadId);
      _threadName = community?.name ?? _threadId;
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;
    final user = context.read<AuthProvider>().user;
    if (user == null) return;

    _msgCtrl.clear();
    await context.read<ChatProvider>().sendMessage(
          threadId: _threadId,
          senderId: user.id,
          senderName: user.fullName,
          content: text,
        );
    _scrollToBottom();
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text(_threadName, style: AppTextStyles.headlineSmall),
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, chatProvider, _) {
                final messages = chatProvider.messagesFor(_threadId);
                if (messages.isEmpty) {
                  return const Center(
                    child: Text(
                      'No messages yet. Say hi! 👋',
                      style: TextStyle(color: AppColors.subtleText),
                    ),
                  );
                }
                return ListView.builder(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.symmetric(
                      vertical: 12, horizontal: 12),
                  itemCount: messages.length,
                  itemBuilder: (context, i) {
                    final msg = messages[i];
                    return _MessageBubble(
                      senderName: msg.senderName,
                      content: msg.content,
                      timestamp: msg.timestamp,
                      isOwn: msg.isOwn,
                    );
                  },
                );
              },
            ),
          ),

          // Input row
          Container(
            color: AppColors.white,
            padding: EdgeInsets.only(
              left: 12,
              right: 12,
              top: 10,
              bottom: MediaQuery.of(context).padding.bottom + 10,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgCtrl,
                    style: AppTextStyles.bodyMedium,
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: 'Message...',
                      hintStyle: AppTextStyles.bodySmall,
                      filled: true,
                      fillColor: AppColors.surface,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _send,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.send_rounded,
                        color: AppColors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final String senderName;
  final String content;
  final DateTime timestamp;
  final bool isOwn;

  const _MessageBubble({
    required this.senderName,
    required this.content,
    required this.timestamp,
    required this.isOwn,
  });

  @override
  Widget build(BuildContext context) {
    final timeStr = DateFormat('h:mm a').format(timestamp);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment:
            isOwn ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isOwn)
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 2),
              child: Text(
                senderName,
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.70,
            ),
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isOwn ? AppColors.primary : AppColors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isOwn ? 16 : 4),
                bottomRight: Radius.circular(isOwn ? 4 : 16),
              ),
              border: isOwn
                  ? null
                  : Border.all(color: const Color(0xFFEEEEEE)),
            ),
            child: Text(
              content,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isOwn ? AppColors.white : AppColors.darkText,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 3, left: 4, right: 4),
            child: Text(
              timeStr,
              style: AppTextStyles.labelSmall.copyWith(fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }
}
