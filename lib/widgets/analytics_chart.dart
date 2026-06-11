import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/colors.dart';

class AnalyticsChart extends StatelessWidget {
  final Map<int, int> distribution;

  const AnalyticsChart({super.key, required this.distribution});

  @override
  Widget build(BuildContext context) {
    final maxY = distribution.values.isEmpty
        ? 10.0
        : distribution.values
                .reduce((a, b) => a > b ? a : b)
                .toDouble() +
            2;

    final bars = List.generate(5, (i) {
      final star = i + 1;
      final count = distribution[star] ?? 0;
      return BarChartGroupData(
        x: star,
        barRods: [
          BarChartRodData(
            toY: count.toDouble(),
            color: AppColors.primary,
            width: 24,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          ),
        ],
      );
    });

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          maxY: maxY,
          barGroups: bars,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => FlLine(
              color: Colors.grey.withOpacity(0.2),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (value, _) => Text(
                  value.toInt().toString(),
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: AppColors.subtleText,
                  ),
                ),
              ),
            ),
            rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) => Text(
                  '${value.toInt()}★',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppColors.darkText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, _, rod, __) => BarTooltipItem(
                '${rod.toY.toInt()} responses',
                GoogleFonts.poppins(
                  color: AppColors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
