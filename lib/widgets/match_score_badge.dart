import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/colors.dart';

class MatchScoreBadge extends StatelessWidget {
  final int score;
  final double size;

  const MatchScoreBadge({
    super.key,
    required this.score,
    this.size = 50,
  });

  Color get _color {
    if (score >= 80) return AppColors.matchHigh;
    if (score >= 50) return AppColors.matchMid;
    return AppColors.matchLow;
  }

  @override
  Widget build(BuildContext context) {
    final clampedPercent = (score.clamp(0, 100)) / 100.0;

    if (size < 40) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: _color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          '$score%',
          style: GoogleFonts.poppins(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: AppColors.white,
          ),
        ),
      );
    }

    return CircularPercentIndicator(
      radius: size / 2,
      lineWidth: size * 0.14,
      percent: clampedPercent,
      center: Text(
        '$score%',
        style: GoogleFonts.poppins(
          fontSize: size * 0.22,
          fontWeight: FontWeight.w700,
          color: _color,
        ),
      ),
      progressColor: _color,
      backgroundColor: _color.withOpacity(0.15),
      circularStrokeCap: CircularStrokeCap.round,
    );
  }
}
