import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Terms of Service"),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Text(
          _termsText,
          style: GoogleFonts.poppins(fontSize: 14, height: 1.6),
        ),
      ),
    );
  }

  final String _termsText = '''
Welcome to NutriScan!

By using this app, you agree to the following Terms of Service. Please read them carefully.

1. Acceptance of Terms
By accessing or using NutriScan, you agree to be bound by these terms. If you do not agree, please do not use the app.

2. Description of Service
NutriScan provides AI-based food recognition and nutritional information. The information is for general guidance only and should not be considered medical advice.

3. User Responsibilities
You agree to use the app responsibly and not misuse or attempt to disrupt the service.

4. Accuracy of Information
While we strive for accuracy, NutriScan does not guarantee that all food recognition or nutritional data is 100% correct.

5. Privacy
Your data is handled according to our Privacy Policy. We do not share personal data without consent.

6. Limitation of Liability
NutriScan is not responsible for any health issues, damages, or losses resulting from reliance on the app’s information.

7. Modifications
We may update these terms at any time. Continued use of the app means you accept the updated terms.

8. Contact Us
If you have questions, contact us at nutriscan08@gmail.com

Thank you for using NutriScan!
''';
}