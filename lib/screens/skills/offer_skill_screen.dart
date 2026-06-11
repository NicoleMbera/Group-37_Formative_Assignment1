import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/colors.dart';
import '../../constants/text_styles.dart';
import '../../models/skill_listing.dart';
import '../../providers/auth_provider.dart';
import '../../providers/skill_provider.dart';

class OfferSkillScreen extends StatefulWidget {
  const OfferSkillScreen({super.key});

  @override
  State<OfferSkillScreen> createState() => _OfferSkillScreenState();
}

class _OfferSkillScreenState extends State<OfferSkillScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _availabilityCtrl = TextEditingController();
  final _maxSessionsCtrl = TextEditingController(text: '3');

  String? _category;
  String? _mode;
  double _maxSessions = 3;
  bool _submitting = false;

  static const _categories = ['Tech', 'Design', 'Writing', 'Speaking', 'Career'];
  static const _modes = ['Online', 'In-person', 'Both'];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _availabilityCtrl.dispose();
    _maxSessionsCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final user = context.read<AuthProvider>().user;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in first')),
      );
      return;
    }

    setState(() => _submitting = true);

    final skill = SkillListing(
      id: 'skill_${DateTime.now().millisecondsSinceEpoch}',
      userId: user.id,
      userName: user.fullName,
      userCampus: user.campus,
      skillTitle: _titleCtrl.text.trim(),
      category: _category!,
      description: _descCtrl.text.trim(),
      mode: _mode!,
      availability: _availabilityCtrl.text.trim(),
      maxSessionsPerWeek: _maxSessions.round(),
      rating: 0.0,
      sessionCount: 0,
      requestCount: 0,
      isAvailable: true,
      createdAt: DateTime.now(),
    );

    try {
      await context.read<SkillProvider>().addSkill(skill);
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Skill listed! Students can now find you 🎉'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not save skill: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title:
            Text('Offer a Skill', style: AppTextStyles.headlineSmall),
        actions: [
          TextButton(
            onPressed: _submitting ? null : _submit,
            child: _submitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    'Save',
                    style: GoogleFonts.poppins(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(
                controller: _titleCtrl,
                label: 'Skill Title *',
                hint: 'e.g. Flutter Mentoring, Essay Writing',
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Title is required'
                    : null,
              ),
              const SizedBox(height: 16),

              // Category
              DropdownButtonFormField<String>(
                value: _category,
                decoration: _inputDecoration('Category *'),
                hint: Text('Select category',
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.subtleText)),
                items: _categories
                    .map((c) => DropdownMenuItem(
                          value: c,
                          child:
                              Text(c, style: AppTextStyles.bodyMedium),
                        ))
                    .toList(),
                validator: (v) =>
                    v == null ? 'Please select a category' : null,
                onChanged: (v) => setState(() => _category = v),
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _descCtrl,
                label: 'Description *',
                hint:
                    'Describe what you can help with, your experience level, and what students will learn...',
                maxLines: 5,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Description is required'
                    : null,
              ),
              const SizedBox(height: 16),

              // Mode
              DropdownButtonFormField<String>(
                value: _mode,
                decoration: _inputDecoration('Mode *'),
                hint: Text('Online, In-person, or Both',
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.subtleText)),
                items: _modes
                    .map((m) => DropdownMenuItem(
                          value: m,
                          child:
                              Text(m, style: AppTextStyles.bodyMedium),
                        ))
                    .toList(),
                validator: (v) =>
                    v == null ? 'Please select a mode' : null,
                onChanged: (v) => setState(() => _mode = v),
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _availabilityCtrl,
                label: 'Availability',
                hint: 'e.g. Weekends, Evenings, Flexible',
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Availability is required'
                    : null,
              ),
              const SizedBox(height: 20),

              // Max sessions slider
              Text('Max sessions per week', style: AppTextStyles.headlineSmall),
              const SizedBox(height: 4),
              Text(
                '${_maxSessions.round()} session${_maxSessions.round() == 1 ? '' : 's'} per week',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Slider(
                value: _maxSessions,
                min: 1,
                max: 10,
                divisions: 9,
                activeColor: AppColors.primary,
                inactiveColor: AppColors.primary.withOpacity(0.2),
                label: _maxSessions.round().toString(),
                onChanged: (v) => setState(() => _maxSessions = v),
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
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
                          'List My Skill',
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: AppTextStyles.bodyMedium,
      decoration: _inputDecoration(label).copyWith(hintText: hint),
      validator: validator,
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle:
          AppTextStyles.bodySmall.copyWith(color: AppColors.subtleText),
      filled: true,
      fillColor: AppColors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.error),
      ),
    );
  }
}
