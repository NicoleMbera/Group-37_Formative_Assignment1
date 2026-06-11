import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/colors.dart';
import '../../constants/text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../services/preferences_service.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  final _nameCtrl = TextEditingController();
  final _skillCtrl = TextEditingController();
  String? _campus;
  String? _role;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      _nameCtrl.text = user.fullName;
      _campus = user.campus;
      _role = user.role;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _skillCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final auth = context.read<AuthProvider>();
    final user = auth.user;
    if (user == null) return;
    final prefs = Provider.of<PreferencesService>(context, listen: false);

    final updated = user.copyWith(
      fullName: _nameCtrl.text.trim(),
      campus: _campus ?? user.campus,
      role: _role ?? user.role,
      skills: prefs.skills,
    );

    await auth.updateUser(updated);
    if (mounted) Navigator.pop(context);
  }

  void _addSkill() async {
    final text = _skillCtrl.text.trim();
    if (text.isEmpty) return;
    final prefs = Provider.of<PreferencesService>(context, listen: false);
    final skills = List<String>.from(prefs.skills);
    if (!skills.contains(text)) {
      skills.add(text);
      await prefs.setSkills(skills);
      setState(() => _skillCtrl.clear());
    }
  }

  void _removeSkill(String s) async {
    final prefs = Provider.of<PreferencesService>(context, listen: false);
    final skills = List<String>.from(prefs.skills);
    skills.remove(s);
    await prefs.setSkills(skills);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final prefs = Provider.of<PreferencesService>(context);
    final skills = prefs.skills;

    return Scaffold(
      appBar: AppBar(
        title: Text('Account', style: AppTextStyles.headlineSmall),
        actions: [
          TextButton(onPressed: _save, child: Text('Save', style: GoogleFonts.poppins(color: AppColors.primary, fontWeight: FontWeight.w700))),
        ],
      ),
      backgroundColor: AppColors.surface,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Full name', style: AppTextStyles.labelSmall),
            const SizedBox(height: 6),
            TextField(controller: _nameCtrl, style: AppTextStyles.bodyMedium),
            const SizedBox(height: 12),
            Text('Campus', style: AppTextStyles.labelSmall),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _campus,
              items: ['Kigali', 'Mauritius'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => setState(() => _campus = v),
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            Text('Role', style: AppTextStyles.labelSmall),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _role,
              items: [
                'Student',
                'Club Leader',
                'Event Organizer',
                'Entrepreneur',
                'Academic Staff'
              ].map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
              onChanged: (v) => setState(() => _role = v),
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            Text('Skills', style: AppTextStyles.headlineSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: skills.map((s) => InputChip(label: Text(s), onDeleted: () => _removeSkill(s))).toList(),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: TextField(controller: _skillCtrl, decoration: const InputDecoration(hintText: 'Add a skill'))),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: _addSkill, child: const Text('Add')),
              ],
            ),
            const SizedBox(height: 24),
            Text('Support', style: AppTextStyles.headlineSmall),
            const SizedBox(height: 8),
            Text('Manage your account details, privacy and notifications here.', style: AppTextStyles.bodySmall.copyWith(color: AppColors.subtleText)),
          ],
        ),
      ),
    );
  }
}
