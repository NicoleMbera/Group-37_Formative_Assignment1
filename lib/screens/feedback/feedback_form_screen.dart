import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/colors.dart';
import '../../constants/text_styles.dart';
import '../../models/feedback.dart';
import '../../providers/auth_provider.dart';
import '../../providers/feed_provider.dart';
import '../../providers/feedback_provider.dart';
import '../../widgets/star_rating_bar.dart';

class FeedbackFormScreen extends StatefulWidget {
  final String eventId;

  const FeedbackFormScreen({super.key, required this.eventId});

  @override
  State<FeedbackFormScreen> createState() => _FeedbackFormScreenState();
}

class _FeedbackFormScreenState extends State<FeedbackFormScreen> {
  String _eventName = '';
  bool _alreadySubmitted = false;
  bool _loading = true;
  bool _submitting = false;
  bool _initialized = false;

  int _overallRating = 0;
  int _contentRating = 0;
  int _organizationRating = 0;
  int _networkingRating = 0;
  bool? _wouldRecommend;
  final _commentsCtrl = TextEditingController();

  String get _eventId => widget.eventId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _init();
    }
  }

  Future<void> _init() async {
    final feedProvider = context.read<FeedProvider>();
    final authProvider = context.read<AuthProvider>();
    final feedbackProvider = context.read<FeedbackProvider>();

    final opp = feedProvider.findById(_eventId);
    _eventName = opp?.title ?? 'Event';

    final userId = authProvider.user?.id ?? '';
    final submitted =
        await feedbackProvider.hasSubmitted(_eventId, userId);

    if (mounted) {
      setState(() {
        _alreadySubmitted = submitted;
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _commentsCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_overallRating == 0 ||
        _contentRating == 0 ||
        _organizationRating == 0 ||
        _networkingRating == 0 ||
        _wouldRecommend == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete all ratings'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final user = context.read<AuthProvider>().user;
    if (user == null) return;

    setState(() => _submitting = true);

    final feedback = EventFeedback(
      id: 'fb_${_eventId}_${DateTime.now().millisecondsSinceEpoch}',
      eventId: _eventId,
      userId: user.id,
      overallRating: _overallRating,
      contentRating: _contentRating,
      organizationRating: _organizationRating,
      networkingRating: _networkingRating,
      wouldRecommend: _wouldRecommend!,
      comments: _commentsCtrl.text.trim(),
      submittedAt: DateTime.now(),
    );

    await context.read<FeedbackProvider>().submitFeedback(feedback);

    if (mounted) {
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thanks for your feedback! 🙏'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          _loading ? 'Feedback' : 'How was $_eventName?',
          style: AppTextStyles.headlineSmall,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : _alreadySubmitted
              ? _AlreadySubmittedView(eventName: _eventName)
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rate your experience at',
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.subtleText),
                      ),
                      Text(
                        _eventName,
                        style: AppTextStyles.headlineMedium,
                      ),
                      const SizedBox(height: 24),

                      // Ratings
                      _RatingSection(
                        label: 'Overall Experience',
                        rating: _overallRating,
                        onRating: (v) =>
                            setState(() => _overallRating = v),
                      ),
                      const SizedBox(height: 20),
                      _RatingSection(
                        label: 'Content Quality',
                        rating: _contentRating,
                        onRating: (v) =>
                            setState(() => _contentRating = v),
                      ),
                      const SizedBox(height: 20),
                      _RatingSection(
                        label: 'Organization',
                        rating: _organizationRating,
                        onRating: (v) =>
                            setState(() => _organizationRating = v),
                      ),
                      const SizedBox(height: 20),
                      _RatingSection(
                        label: 'Networking Value',
                        rating: _networkingRating,
                        onRating: (v) =>
                            setState(() => _networkingRating = v),
                      ),
                      const SizedBox(height: 24),

                      // Would Recommend
                      Text(
                        'Would you recommend this event?',
                        style: AppTextStyles.headlineSmall,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _RecommendButton(
                            label: '👍 Yes',
                            selected: _wouldRecommend == true,
                            onTap: () =>
                                setState(() => _wouldRecommend = true),
                          ),
                          const SizedBox(width: 12),
                          _RecommendButton(
                            label: '👎 No',
                            selected: _wouldRecommend == false,
                            onTap: () =>
                                setState(() => _wouldRecommend = false),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Comments
                      Text(
                        'Any comments for the organizer?',
                        style: AppTextStyles.headlineSmall,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Optional',
                        style: AppTextStyles.bodySmall,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _commentsCtrl,
                        maxLines: 4,
                        style: AppTextStyles.bodyMedium,
                        decoration: InputDecoration(
                          hintText:
                              'Share what you loved or what could be improved...',
                          hintStyle: AppTextStyles.bodySmall,
                          filled: true,
                          fillColor: AppColors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                                color: Color(0xFFDDDDDD)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                                color: Color(0xFFDDDDDD)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                                color: AppColors.primary, width: 2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _submitting ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.white,
                            padding:
                                const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          child: _submitting
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    color: AppColors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  'Submit Feedback',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
    );
  }
}

class _RatingSection extends StatelessWidget {
  final String label;
  final int rating;
  final ValueChanged<int> onRating;

  const _RatingSection({
    required this.label,
    required this.rating,
    required this.onRating,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.titleMedium),
          StarRatingBar(
            rating: rating,
            onRating: onRating,
            starSize: 28,
          ),
        ],
      ),
    );
  }
}

class _RecommendButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _RecommendButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: selected ? AppColors.primary : const Color(0xFFDDDDDD),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: selected ? AppColors.white : AppColors.darkText,
          ),
        ),
      ),
    );
  }
}

class _AlreadySubmittedView extends StatelessWidget {
  final String eventName;

  const _AlreadySubmittedView({required this.eventName});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_outline,
                  size: 64, color: Color(0xFF4CAF50)),
              const SizedBox(height: 16),
              Text(
                'Already Rated!',
                style: AppTextStyles.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'You already submitted feedback for $eventName. Thank you!',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.subtleText),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
