import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/colors.dart';
import '../../constants/text_styles.dart';
import '../../models/opportunity.dart';
import '../../providers/auth_provider.dart';
import '../../providers/feed_provider.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _maxParticipantsCtrl = TextEditingController();
  final _tagsCtrl = TextEditingController();

  String? _category;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _publishing = false;

  static const _categories = ['Events', 'Hackathons', 'Internships', 'Workshops'];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _locationCtrl.dispose();
    _maxParticipantsCtrl.dispose();
    _tagsCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Future<void> _publish() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date')),
      );
      return;
    }
    if (_selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a time')),
      );
      return;
    }

    final user = context.read<AuthProvider>().user;
    if (user == null) return;

    setState(() => _publishing = true);

    final tags = _tagsCtrl.text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    final maxP = int.tryParse(_maxParticipantsCtrl.text) ?? 50;
    final timeStr =
        _selectedTime!.format(context);

    final opp = Opportunity(
      id: 'opp_${DateTime.now().millisecondsSinceEpoch}',
      title: _titleCtrl.text.trim(),
      category: _category!,
      description: _descCtrl.text.trim(),
      organizer: user.fullName,
      date: _selectedDate!,
      time: timeStr,
      location: _locationCtrl.text.trim(),
      maxParticipants: maxP,
      rsvpCount: 0,
      tags: tags,
      requiredSkills: [],
    );

    await context.read<FeedProvider>().addOpportunity(opp);

    if (mounted) {
      setState(() => _publishing = false);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Posted successfully! 🎉'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    if (user == null || !user.isOrganizer) {
      return Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_outline,
                    size: 64, color: AppColors.subtleText),
                const SizedBox(height: 16),
                Text(
                  'Only organizers can post',
                  style: AppTextStyles.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Contact the team to get organizer access.',
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.subtleText),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Go Back'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text('Create Post', style: AppTextStyles.headlineSmall),
        actions: [
          TextButton(
            onPressed: _publishing ? null : _publish,
            child: _publishing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    'Publish',
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
              // Image placeholder
              GestureDetector(
                onTap: () {},
                child: Container(
                  height: 160,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEEEEE),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: const Color(0xFFCCCCCC), width: 1.5),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add_a_photo_outlined,
                          size: 40, color: AppColors.subtleText),
                      const SizedBox(height: 8),
                      Text(
                        'Add Photo',
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.subtleText),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              _buildTextField(
                controller: _titleCtrl,
                label: 'Event Title *',
                hint: 'Enter a clear, descriptive title',
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
                          child: Text(c, style: AppTextStyles.bodyMedium),
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
                hint: 'Describe your event in detail...',
                maxLines: 5,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Description is required'
                    : null,
              ),
              const SizedBox(height: 16),

              // Date picker
              GestureDetector(
                onTap: _pickDate,
                child: AbsorbPointer(
                  child: TextFormField(
                    style: AppTextStyles.bodyMedium,
                    controller: TextEditingController(
                      text: _selectedDate == null
                          ? ''
                          : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                    ),
                    decoration: _inputDecoration('Date *').copyWith(
                      hintText: 'Select date',
                      suffixIcon: const Icon(Icons.calendar_today_outlined,
                          color: AppColors.subtleText),
                    ),
                    validator: (_) =>
                        _selectedDate == null ? 'Date is required' : null,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Time picker
              GestureDetector(
                onTap: _pickTime,
                child: AbsorbPointer(
                  child: TextFormField(
                    style: AppTextStyles.bodyMedium,
                    controller: TextEditingController(
                      text: _selectedTime == null
                          ? ''
                          : _selectedTime!.format(context),
                    ),
                    decoration: _inputDecoration('Time *').copyWith(
                      hintText: 'Select time',
                      suffixIcon: const Icon(Icons.access_time_outlined,
                          color: AppColors.subtleText),
                    ),
                    validator: (_) =>
                        _selectedTime == null ? 'Time is required' : null,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _locationCtrl,
                label: 'Location *',
                hint: 'Room, building, or online link',
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Location is required'
                    : null,
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _maxParticipantsCtrl,
                label: 'Max Participants',
                hint: 'e.g. 50',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _tagsCtrl,
                label: 'Tags',
                hint: 'e.g. Tech, Innovation, Leadership',
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _publishing ? null : _publish,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: _publishing
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: AppColors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Publish Event',
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
