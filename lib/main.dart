import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'constants/colors.dart';
import 'providers/auth_provider.dart';
import 'providers/campus_pulse_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/community_provider.dart';
import 'providers/feed_provider.dart';
import 'providers/feedback_provider.dart';
import 'providers/rsvp_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/skill_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/campus_pulse/campus_pulse_screen.dart';
import 'screens/chat/chat_detail_screen.dart';
import 'screens/chat/chats_screen.dart';
import 'screens/communities/communities_screen.dart';
import 'screens/communities/community_detail_screen.dart';
import 'screens/explore/explore_screen.dart';
import 'screens/feedback/feedback_analytics_screen.dart';
import 'screens/feedback/feedback_form_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/home/opportunity_detail_screen.dart';
import 'screens/onboarding/interests_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/post/create_post_screen.dart';
import 'screens/profile/my_rsvps_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/profile/account_settings_screen.dart';
import 'screens/profile/notifications_screen.dart';
import 'screens/profile/help_support_screen.dart';
import 'screens/skills/offer_skill_screen.dart';
import 'screens/skills/skill_detail_screen.dart';
import 'screens/skills/skills_marketplace_screen.dart';
import 'services/database_service.dart';
import 'services/preferences_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await PreferencesService.create();
  final db = DatabaseService();
  runApp(MyApp(prefs: prefs, db: db));
}

class MyApp extends StatelessWidget {
  final PreferencesService prefs;
  final DatabaseService db;

  const MyApp({super.key, required this.prefs, required this.db});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(prefs)),
        ChangeNotifierProvider(create: (_) => RsvpProvider(prefs)),
        ChangeNotifierProvider(create: (_) => FeedProvider(db)),
        ChangeNotifierProvider(create: (_) => CommunityProvider(prefs)),
        ChangeNotifierProvider(create: (_) => ChatProvider(db)),
        ChangeNotifierProvider(create: (_) => FeedbackProvider(db)),
        ChangeNotifierProvider(create: (_) => SkillProvider(db)),
        ChangeNotifierProvider(create: (_) => CampusPulseProvider(prefs)),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        Provider<PreferencesService>.value(value: prefs),
      ],
      child: MaterialApp(
        title: 'ALU Connect',
        debugShowCheckedModeBanner: false,
        theme: _buildTheme(),
        initialRoute: prefs.isOnboardingDone
            ? (prefs.userJson != null ? '/home' : '/login')
            : '/onboarding',
        routes: {
          '/onboarding': (_) => const OnboardingScreen(),
          '/interests': (_) => const InterestsScreen(),
          '/login': (_) => const LoginScreen(),
          '/home': (_) => const HomeScreen(),
          '/explore': (_) => const ExploreScreen(),
          '/communities': (_) => const CommunitiesScreen(),
          '/create-post': (_) => const CreatePostScreen(),
          '/campus-pulse': (_) => const CampusPulseScreen(),
          '/profile': (_) => const ProfileScreen(),
          '/my-rsvps': (_) => const MyRsvpsScreen(),
          '/skills': (_) => const SkillsMarketplaceScreen(),
          '/offer-skill': (_) => const OfferSkillScreen(),
          '/chats': (_) => const ChatsScreen(),
          '/account': (_) => const AccountSettingsScreen(),
          '/notifications': (_) => const NotificationsScreen(),
          '/help-support': (_) => const HelpSupportScreen(),
        },
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/opportunity-detail':
              return MaterialPageRoute(
                builder: (_) =>
                    OpportunityDetailScreen(id: settings.arguments as String),
              );
            case '/community-detail':
              return MaterialPageRoute(
                builder: (_) =>
                    CommunityDetailScreen(id: settings.arguments as String),
              );
            case '/chat-detail':
              return MaterialPageRoute(
                builder: (_) =>
                    ChatDetailScreen(threadId: settings.arguments as String),
              );
            case '/feedback-form':
              return MaterialPageRoute(
                builder: (_) =>
                    FeedbackFormScreen(eventId: settings.arguments as String),
              );
            case '/feedback-analytics':
              return MaterialPageRoute(
                builder: (_) => FeedbackAnalyticsScreen(
                    eventId: settings.arguments as String),
              );
            case '/skill-detail':
              return MaterialPageRoute(
                builder: (_) =>
                    SkillDetailScreen(skillId: settings.arguments as String),
              );
            default:
              return null;
          }
        },
      ),
    );
  }

  ThemeData _buildTheme() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.surface,
        onPrimary: AppColors.white,
        onSurface: AppColors.darkText,
      ),
    );
    return base.copyWith(
      textTheme: GoogleFonts.poppinsTextTheme(base.textTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.darkText,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.darkText,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: GoogleFonts.poppins(
              fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: GoogleFonts.poppins(
              fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle:
            GoogleFonts.poppins(color: AppColors.subtleText, fontSize: 14),
      ),
      cardTheme: CardThemeData(
        color: AppColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFEEEEEE)),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.primary,
        labelStyle: GoogleFonts.poppins(
            fontSize: 12, fontWeight: FontWeight.w500),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.darkText,
        contentTextStyle:
            GoogleFonts.poppins(color: AppColors.white),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        behavior: SnackBarBehavior.floating,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.subtleText,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
