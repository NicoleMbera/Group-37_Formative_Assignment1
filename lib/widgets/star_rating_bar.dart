import 'package:flutter/material.dart';
import '../constants/colors.dart';

class StarRatingBar extends StatelessWidget {
  final int rating;
  final ValueChanged<int> onRating;
  final bool readOnly;
  final double starSize;

  const StarRatingBar({
    super.key,
    required this.rating,
    required this.onRating,
    this.readOnly = false,
    this.starSize = 32,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starIndex = index + 1;
        final isFilled = starIndex <= rating;
        return GestureDetector(
          onTap: readOnly ? null : () => onRating(starIndex),
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 1.0, end: isFilled ? 1.2 : 1.0),
            duration: const Duration(milliseconds: 200),
            curve: Curves.elasticOut,
            builder: (_, scale, child) => Transform.scale(
              scale: scale,
              child: child,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Icon(
                isFilled ? Icons.star_rounded : Icons.star_border_rounded,
                size: starSize,
                color: isFilled ? AppColors.accent : AppColors.subtleText,
              ),
            ),
          ),
        );
      }),
    );
  }
}
