import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:main_app/HomePageAll/HomePage.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => HomePage()),
            );
          },
          icon: Icon(Icons.arrow_back_ios_new),
        ),
        title: const Text("Help & Support"),
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔰 Header
            Center(
              child: Column(
                children: [
                  Image.asset("assets/images/appbarlogo.png", height: 100),

                  const SizedBox(height: 10),
                  Text(
                    "Need Help?",
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "We're here to assist you",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 📌 FAQs
            Text(
              "Frequently Asked Questions",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            _buildFAQ(
              "How does NutriScan work?",
              "NutriScan uses ML to detect food from images and provides nutritional information instantly.",
            ),

            _buildFAQ(
              "Why is my food not recognized?",
              "Ensure the image is clear and well-lit. Some uncommon foods may not be supported yet.",
            ),

            _buildFAQ(
              "Is the app free?",
              "Yes, basic features are free. Future premium features may be added.",
            ),

            _buildFAQ(
              "Can I track my daily diet?",
              "Yes, NutriScan allows you to monitor your daily food intake.",
            ),

            const SizedBox(height: 20),

            // 📞 Contact Section
            Text(
              "Contact Support",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            _buildContactTile(
              Icons.email,
              "Email Support",
              "nutriscan08@gmail.com",
            ),
            _buildContactTile(Icons.phone, "Call Us", "+91 9322652272"),

            const SizedBox(height: 20),

            // ❤️ Footer
            Center(
              child: Text(
                "We’re always here to help you 💚",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 FAQ Widget
  Widget _buildFAQ(String question, String answer) {
    return Card(
      color: Colors.white,
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ExpansionTile(
        title: Text(question, style: GoogleFonts.poppins(fontSize: 14)),
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(answer, style: GoogleFonts.poppins(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  // 🔹 Contact Tile
  Widget _buildContactTile(IconData icon, String title, String subtitle) {
    return Card(
      color: Colors.white,
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.white,
          child: Icon(icon, color: Colors.green),
        ),
        title: Text(title, style: GoogleFonts.poppins(fontSize: 14)),
        subtitle: Text(subtitle, style: GoogleFonts.poppins(fontSize: 12)),
      ),
    );
  }
}
