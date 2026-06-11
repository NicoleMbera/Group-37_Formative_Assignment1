import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/colors.dart';
import '../../constants/text_styles.dart';
import '../../services/preferences_service.dart';
import '../../widgets/interest_chip.dart';

const _interests = [
  'Tech',
  'Entrepreneurship',
  'Leadership',
  'Arts & Culture',
  'Sports',
  'Wellness',
  'Debate',
  'Environment',
  'Innovation',
  'Design',
  'Research',
  'Social Impact',
];

const _pathways = [
  'BSc Computer Science',
  'BSc Business',
  'BSc Electrical Engineering',
  'Global Challenges',
  'Entrepreneurship',
  'Law',
  'Health Sciences',
];

const _skillOptions = [
  'Flutter',
  'Python',
  'Public Speaking',
  'Graphic Design',
  'Video Editing',
  'Data Analysis',
  'Writing',
  'Project Management',
  'UI/UX',
  'Marketing',
];

class InterestsScreen extends StatefulWidget {
  const InterestsScreen({super.key});

  @override
  State<InterestsScreen> createState() => _InterestsScreenState();
}

class _InterestsScreenState extends State<InterestsScreen> {
  final Set<String> _selectedInterests = {};
  String? _selectedPathway;
  final Set<String> _selectedSkills = {};
  bool _loading = false;

  String? _interestError;
  String? _pathwayError;
  String? _skillError;

  PreferencesService? _prefs;

  @override
  void initState() {
    super.initState();
    PreferencesService.create().then((svc) {
      if (mounted) setState(() => _prefs = svc);
    });
  }

  bool get _canContinue =>
      _selectedInterests.length >= 3 &&
      _selectedPathway != null &&
      _selectedSkills.isNotEmpty;

  Future<void> _onContinue() async {
    setState(() {
      _interestError = _selectedInterests.length < 3
          ? 'Please select at least 3 interests'
          : null;
      _pathwayError =
          _selectedPathway == null ? 'Please select your pathway' : null;
      _skillError = _selectedSkills.isEmpty
          ? 'Please select at least one skill'
          : null;
    });

    if (_interestError != null ||
        _pathwayError != null ||
        _skillError != null) return;

    setState(() => _loading = true);
    final prefs = _prefs;
    if (prefs != null) {
      await prefs.setInterests(_selectedInterests.toList());
      await prefs.setPathway(_selectedPathway!);
      await prefs.setSkills(_selectedSkills.toList());
      await prefs.setOnboardingDone();
    }
    if (mounted) {
      setState(() => _loading = false);
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'What are you into?',
                style: AppTextStyles.displayMedium,
              ),
              const SizedBox(height: 6),
              Text(
                "We'll personalise your feed and match you to opportunities",
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.subtleText,
                ),
              ),
              const SizedBox(height: 28),

              // Interests
              _SectionLabel(
                title: 'Select your interests',
                subtitle: 'Choose at least 3',
                error: _interestError,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _interests.map((interest) {
                  return InterestChip(
                    label: interest,
                    selected: _selectedInterests.contains(interest),
                    onTap: () => setState(() {
                      if (_selectedInterests.contains(interest)) {
                        _selectedInterests.remove(interest);
                      } else {
                        _selectedInterests.add(interest);
                      }
                      _interestError = null;
                    }),
                  );
                }).toList(),
              ),
              const SizedBox(height: 28),

              // Pathway
              _SectionLabel(
                title: "What's your major/pathway?",
                error: _pathwayError,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedPathway,
                hint: Text(
                  'Select your pathway',
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.subtleText),
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: Color(0xFFDDDDDD)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: Color(0xFFDDDDDD)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 14),
                ),
                items: _pathways
                    .map((p) => DropdownMenuItem(
                          value: p,
                          child: Text(p, style: AppTextStyles.bodyMedium),
                        ))
                    .toList(),
                onChanged: (v) => setState(() {
                  _selectedPathway = v;
                  _pathwayError = null;
                }),
              ),
              const SizedBox(height: 28),

              // Skills
              _SectionLabel(
                title: 'What skills do you have?',
                subtitle: 'Choose all that apply',
                error: _skillError,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _skillOptions.map((skill) {
                  return InterestChip(
                    label: skill,
                    selected: _selectedSkills.contains(skill),
                    onTap: () => setState(() {
                      if (_selectedSkills.contains(skill)) {
                        _selectedSkills.remove(skill);
                      } else {
                        _selectedSkills.add(skill);
                      }
                      _skillError = null;
                    }),
                  );
                }).toList(),
              ),
              const SizedBox(height: 36),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _onContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: AppColors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Continue',
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
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? error;

  const _SectionLabel({
    required this.title,
    this.subtitle,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.headlineSmall),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(subtitle!,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.subtleText,
              )),
        ],
        if (error != null) ...[
          const SizedBox(height: 4),
          Text(
            error!,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.error,
            ),
          ),
        ],
      ],
    );
  }
}
