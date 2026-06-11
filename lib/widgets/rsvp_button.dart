import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';
import '../providers/rsvp_provider.dart';

class RsvpButton extends StatefulWidget {
  final String eventId;
  final String eventName;

  const RsvpButton({
    super.key,
    required this.eventId,
    required this.eventName,
  });

  @override
  State<RsvpButton> createState() => _RsvpButtonState();
}

class _RsvpButtonState extends State<RsvpButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
      lowerBound: 0.85,
      upperBound: 1.0,
      value: 1.0,
    );
    _scaleAnim = _controller;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onTap(bool isGoing) async {
    await _controller.reverse();
    if (!mounted) return;
    await context.read<RsvpProvider>().toggleGoing(widget.eventId);
    if (!mounted) return;
    await _controller.forward();
    final nowGoing = !isGoing;
    final msg = nowGoing
        ? "You're going to ${widget.eventName}! 🎉"
        : 'RSVP removed';
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RsvpProvider>(
      builder: (context, rsvpProvider, _) {
        final isGoing = rsvpProvider.isGoing(widget.eventId);
        return ScaleTransition(
          scale: _scaleAnim,
          child: ElevatedButton(
            onPressed: () => _onTap(isGoing),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isGoing ? const Color(0xFF4CAF50) : AppColors.primary,
              foregroundColor: AppColors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 0,
            ),
            child: Text(
              isGoing ? 'Going ✓' : 'RSVP',
              style: AppTextStyles.labelLarge.copyWith(fontSize: 13),
            ),
          ),
        );
      },
    );
  }
}
