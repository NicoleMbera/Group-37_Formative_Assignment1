import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../constants/text_styles.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Help & Support', style: AppTextStyles.headlineSmall)),
      backgroundColor: AppColors.surface,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            SizedBox(height: 8),
            Text('Help & Support', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            SizedBox(height: 12),
            Text('For help with ALU Connect, contact support@alu.edu or visit the student helpdesk.'),
            SizedBox(height: 16),
            Text('FAQ', style: TextStyle(fontWeight: FontWeight.w700)),
            SizedBox(height: 8),
            Text('• How do I register? Use the Register tab on the login screen.'),
            Text('• How do I post an event? Club leaders and organisers can post from the home screen.'),
          ],
        ),
      ),
    );
  }
}
