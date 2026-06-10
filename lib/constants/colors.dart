import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFFC8102E);
  static const Color white = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF5F5F5);
  static const Color accent = Color(0xFFFFB300);
  static const Color darkText = Color(0xFF1A1A1A);
  static const Color subtleText = Color(0xFF757575);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color error = Color(0xFFD32F2F);

  // Match score
  static const Color matchHigh = Color(0xFF4CAF50);
  static const Color matchMid = Color(0xFFFFB300);
  static const Color matchLow = Color(0xFF9E9E9E);

  // Category colors
  static const Color eventColor = Color(0xFF1565C0);
  static const Color hackathonColor = Color(0xFF6A1B9A);
  static const Color internshipColor = Color(0xFF2E7D32);
  static const Color workshopColor = Color(0xFFE65100);
  static const Color opportunityColor = Color(0xFF00838F);

  static Color matchColor(int score) {
    if (score >= 80) return matchHigh;
    if (score >= 50) return matchMid;
    return matchLow;
  }

  static Color categoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'event':
      case 'events':
        return eventColor;
      case 'hackathon':
      case 'hackathons':
        return hackathonColor;
      case 'internship':
      case 'internships':
        return internshipColor;
      case 'workshop':
      case 'workshops':
        return workshopColor;
      default:
        return opportunityColor;
    }
  }
}
